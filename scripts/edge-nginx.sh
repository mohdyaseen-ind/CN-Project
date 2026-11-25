#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "$0")/.." && pwd)"
CONF="configs/edge/nginx.conf"
PID_FILE="$ROOT/var/run/nginx-edge.pid"

if ! command -v brew >/dev/null 2>&1 || ! brew list --versions nginx >/dev/null 2>&1; then
    printf 'Homebrew nginx is not installed. Install it after approval, then retry.\n' >&2
    exit 1
fi
NGINX="$(brew --prefix nginx)/bin/nginx"

nginx_test() {
    "$NGINX" -e stderr -t -p "$ROOT/" -c "$CONF"
}

verified_pid() {
    [[ -f "$PID_FILE" ]] || return 1
    local pid
    pid="$(<"$PID_FILE")"
    kill -0 "$pid" 2>/dev/null &&
        ps -p "$pid" -o command= | grep -Fq "$CONF" || return 1
    printf '%s\n' "$pid"
}

case "${1:-}" in
    config-test)
        [[ -r "$ROOT/edge/certs/app.crt" && -r "$ROOT/edge/certs/app.key" ]] || {
            printf 'TLS certificate/key missing; run configs/tls/gen-cert.sh first.\n' >&2
            exit 1
        }
        mkdir -p "$ROOT/var/run" "$ROOT/var/log"
        nginx_test
        ;;
    start)
        [[ -r "$ROOT/edge/certs/app.crt" && -r "$ROOT/edge/certs/app.key" ]] || {
            printf 'TLS certificate/key missing; run configs/tls/gen-cert.sh first.\n' >&2
            exit 1
        }
        mkdir -p "$ROOT/var/run" "$ROOT/var/log"
        nginx_test
        if pid="$(verified_pid)"; then
            printf 'Main edge nginx already running (pid %s)\n' "$pid"
            exit 0
        fi
        if [[ -f "$PID_FILE" ]]; then
            stale="$(<"$PID_FILE")"
            if kill -0 "$stale" 2>/dev/null; then
                printf 'Refusing PID file for unrelated live process %s\n' "$stale" >&2
                exit 1
            fi
            rm -f "$PID_FILE"
        fi
        "$NGINX" -e stderr -p "$ROOT/" -c "$CONF"
        ;;
    status)
        pid="$(verified_pid)" || { printf 'Main edge nginx is not running.\n' >&2; exit 1; }
        printf 'Main edge nginx master: pid %s\n' "$pid"
        ;;
    reload)
        nginx_test
        pid="$(verified_pid)" || { printf 'Refusing to reload an unverified nginx process.\n' >&2; exit 1; }
        "$NGINX" -e stderr -p "$ROOT/" -c "$CONF" -s reload
        printf 'Reload requested for main edge nginx (pid %s).\n' "$pid"
        ;;
    stop)
        if [[ ! -f "$PID_FILE" ]]; then
            printf 'Main edge nginx PID file not found; nothing to stop.\n'
            exit 0
        fi
        pid="$(verified_pid)" || {
            other="$(<"$PID_FILE")"
            if kill -0 "$other" 2>/dev/null; then
                printf 'Refusing to stop unverified process %s.\n' "$other" >&2
                exit 1
            fi
            rm -f "$PID_FILE"
            printf 'Removed stale main edge PID file.\n'
            exit 0
        }
        "$NGINX" -e stderr -p "$ROOT/" -c "$CONF" -s quit
        printf 'Graceful stop requested for main edge nginx (pid %s).\n' "$pid"
        ;;
    *)
        printf 'Usage: %s {config-test|start|status|reload|stop}\n' "$0" >&2
        exit 2
        ;;
esac
