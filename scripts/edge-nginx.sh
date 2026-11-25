#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "$0")/.." && pwd)"
NGINX="$(brew --prefix nginx)/bin/nginx"
CONF="configs/edge/nginx.conf"
PID_FILE="$ROOT/var/run/nginx-main.pid"
CERT_FILE="$ROOT/edge/certs/app.crt"
KEY_FILE="$ROOT/edge/certs/app.key"
if [[ -n "${EDGE_CA_FILE:-}" ]]; then
    CA_FILE="$EDGE_CA_FILE"
elif [[ -r "$ROOT/edge/certs/ca.crt" &&
        -r "$CERT_FILE" &&
        "$(openssl verify -CAfile "$ROOT/edge/certs/ca.crt" "$CERT_FILE" 2>/dev/null || true)" == *": OK" ]]; then
    CA_FILE="$ROOT/edge/certs/ca.crt"
else
    CA_FILE="$CERT_FILE"
fi

prepare_paths() {
    mkdir -p "$ROOT/var/run" "$ROOT/var/log"
}

nginx_test() {
    prepare_paths
    if [[ ! -e "$CERT_FILE" || ! -e "$KEY_FILE" ]]; then
        printf 'Main-edge certificate/key missing under %s/edge/certs\n' "$ROOT" >&2
        printf 'Generate a local certificate with bash configs/tls/gen-cert.sh\n' >&2
        return 1
    fi
    if [[ ! -r "$CERT_FILE" || ! -r "$KEY_FILE" ]]; then
        printf 'Main-edge certificate/key must be readable by the nginx user; keep the key local and private\n' >&2
        return 1
    fi
    "$NGINX" -e stderr -t -p "$ROOT/" -c "$CONF"
}

is_main_edge() {
    local pid="$1"
    kill -0 "$pid" 2>/dev/null &&
        ps -p "$pid" -o command= | grep -Fq 'configs/edge/nginx.conf'
}

verified_pid() {
    if [[ ! -f "$PID_FILE" ]]; then
        printf 'Main-edge nginx PID file not found\n' >&2
        return 1
    fi
    local pid
    pid="$(<"$PID_FILE")"
    if ! is_main_edge "$pid"; then
        printf 'PID file is stale or does not identify project main nginx\n' >&2
        return 1
    fi
    printf '%s\n' "$pid"
}

edge_status() {
    local pid
    pid="$(verified_pid)"
    printf 'Main-edge nginx master: pid %s\n' "$pid"
    curl --noproxy '*' --silent --show-error --fail --include --max-time 8 \
        --cacert "$CA_FILE" \
        --resolve app.team1.test:8443:127.0.0.1 \
        https://app.team1.test:8443/api/status
}

check_upstreams() {
    local failures=0 endpoint host port
    for endpoint in '10.7.28.39 3001' '10.7.18.197 3002'; do
        host="${endpoint% *}"
        port="${endpoint##* }"
        printf 'Checking %s:%s\n' "$host" "$port"
        if ! nc -G 3 -vz "$host" "$port"; then
            failures=1
        fi
    done
    return "$failures"
}

probe_backends() {
    local request response
    for request in 1 2 3 4 5 6; do
        printf 'Request %s: ' "$request"
        response="$(curl --noproxy '*' --silent --show-error --fail \
            --max-time 8 --cacert "$CA_FILE" \
            --resolve app.team1.test:8443:127.0.0.1 \
            --dump-header - --output /dev/null \
            https://app.team1.test:8443/api/status)"
        printf '%s\n' "$response" | tr -d '\r' | grep -iE '^(HTTP/|x-backend:)'
    done
}

case "${1:-}" in
    config-test)
        nginx_test
        ;;
    start)
        nginx_test
        if [[ -f "$PID_FILE" ]]; then
            pid="$(<"$PID_FILE")"
            if kill -0 "$pid" 2>/dev/null; then
                if is_main_edge "$pid"; then
                    printf 'Project main nginx already running (pid %s)\n' "$pid"
                    edge_status
                    exit
                fi
                printf 'Refusing to use PID file for unrelated live process %s\n' "$pid" >&2
                exit 1
            fi
            rm -f "$PID_FILE"
        fi
        "$NGINX" -e stderr -p "$ROOT/" -c "$CONF"
        for ((attempt = 0; attempt < 40; attempt++)); do
            if [[ -f "$PID_FILE" ]] && is_main_edge "$(<"$PID_FILE")"; then
                edge_status
                exit
            fi
            sleep 0.25
        done
        printf 'Main nginx failed to start; inspect %s\n' \
            "$ROOT/var/log/nginx-main-error.log" >&2
        exit 1
        ;;
    status)
        edge_status
        ;;
    upstreams)
        check_upstreams
        ;;
    probe)
        verified_pid >/dev/null
        probe_backends
        ;;
    reload)
        nginx_test
        pid="$(verified_pid)"
        "$NGINX" -e stderr -p "$ROOT/" -c "$CONF" -s reload
        printf 'Reload signal sent to project main nginx (pid %s)\n' "$pid"
        edge_status
        ;;
    stop)
        pid="$(verified_pid)"
        "$NGINX" -e stderr -p "$ROOT/" -c "$CONF" -s quit
        for ((attempt = 0; attempt < 50; attempt++)); do
            if ! kill -0 "$pid" 2>/dev/null; then
                rm -f "$PID_FILE"
                printf 'Project main nginx stopped (pid %s)\n' "$pid"
                exit 0
            fi
            sleep 0.1
        done
        printf 'Main nginx did not stop cleanly; inspect pid %s\n' "$pid" >&2
        exit 1
        ;;
    *)
        printf 'Usage: %s {config-test|start|status|upstreams|probe|reload|stop}\n' "$0" >&2
        exit 2
        ;;
esac
