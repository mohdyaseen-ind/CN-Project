#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "$0")/.." && pwd)"
NGINX="$(brew --prefix nginx)/bin/nginx"
CONF="configs/edge/nginx-standby.conf"
PID_FILE="$ROOT/var/run/nginx-standby.pid"
if [[ -r "$ROOT/edge/certs/ca.crt" ]]; then
    CA_FILE="$ROOT/edge/certs/ca.crt"
else
    CA_FILE="$ROOT/edge/certs/app.crt"
fi

nginx_test() {
    "$NGINX" -e stderr -t -p "$ROOT/" -c "$CONF"
}

nginx_status() {
    if [[ ! -f "$PID_FILE" ]]; then
        printf 'Standby nginx PID file not found\n' >&2
        return 1
    fi
    local pid
    pid="$(<"$PID_FILE")"
    if ! kill -0 "$pid" 2>/dev/null ||
        ! ps -p "$pid" -o command= | grep -Fq 'nginx-standby.conf'; then
        printf 'Standby nginx PID file is stale or does not identify this config\n' >&2
        return 1
    fi
    printf 'Standby nginx master: pid %s\n' "$pid"
    curl --silent --show-error --fail --include --max-time 8 \
        --cacert "$CA_FILE" \
        --resolve app.team1.test:8443:127.0.0.1 \
        https://app.team1.test:8443/api/status
}

case "${1:-}" in
    config-test)
        mkdir -p "$ROOT/var/run" "$ROOT/var/log"
        nginx_test
        ;;
    start)
        mkdir -p "$ROOT/var/run" "$ROOT/var/log"
        if [[ ! -r "$ROOT/edge/certs/app.crt" || ! -r "$ROOT/edge/certs/app.key" ]]; then
            printf 'Standby certificate/key missing; see TLS setup instructions\n' >&2
            exit 1
        fi
        nginx_test
        if [[ -f "$PID_FILE" ]]; then
            pid="$(<"$PID_FILE")"
            if kill -0 "$pid" 2>/dev/null; then
                if ps -p "$pid" -o command= | grep -Fq 'nginx-standby.conf'; then
                    printf 'Standby nginx already running (pid %s)\n' "$pid"
                    nginx_status
                    exit
                fi
                printf 'Refusing to use PID file for unrelated live process %s\n' "$pid" >&2
                exit 1
            fi
            rm -f "$PID_FILE"
        fi
        "$NGINX" -e stderr -p "$ROOT/" -c "$CONF"
        for ((attempt = 0; attempt < 40; attempt++)); do
            if [[ -f "$PID_FILE" ]] && kill -0 "$(<"$PID_FILE")" 2>/dev/null; then
                nginx_status
                exit
            fi
            sleep 0.25
        done
        printf 'Standby nginx failed to start; inspect %s\n' \
            "$ROOT/var/log/nginx-standby-error.log" >&2
        exit 1
        ;;
    status)
        nginx_status
        ;;
    reload)
        nginx_test
        if [[ ! -f "$PID_FILE" ]]; then
            printf 'Standby nginx PID file not found; cannot reload\n' >&2
            exit 1
        fi
        pid="$(<"$PID_FILE")"
        if ! kill -0 "$pid" 2>/dev/null ||
            ! ps -p "$pid" -o command= | grep -Fq 'nginx-standby.conf'; then
            printf 'Refusing to reload an unverified standby nginx process\n' >&2
            exit 1
        fi
        "$NGINX" -e stderr -p "$ROOT/" -c "$CONF" -s reload
        nginx_status
        ;;
    stop)
        if [[ ! -f "$PID_FILE" ]]; then
            printf 'Standby nginx PID file not found; no project-managed process to stop\n'
            exit 0
        fi
        pid="$(<"$PID_FILE")"
        if ! kill -0 "$pid" 2>/dev/null; then
            rm -f "$PID_FILE"
            printf 'Removed stale standby nginx PID file\n'
            exit 0
        fi
        if ! ps -p "$pid" -o command= | grep -Fq 'nginx-standby.conf'; then
            printf 'Refusing to signal unrelated process %s\n' "$pid" >&2
            exit 1
        fi
        "$NGINX" -e stderr -p "$ROOT/" -c "$CONF" -s quit
        for ((attempt = 0; attempt < 50; attempt++)); do
            if ! kill -0 "$pid" 2>/dev/null; then
                rm -f "$PID_FILE"
                printf 'Standby nginx stopped (pid %s)\n' "$pid"
                exit 0
            fi
            sleep 0.1
        done
        printf 'Standby nginx did not stop cleanly; inspect pid %s\n' "$pid" >&2
        exit 1
        ;;
    *)
        printf 'Usage: %s {config-test|start|status|reload|stop}\n' "$0" >&2
        exit 2
        ;;
esac
