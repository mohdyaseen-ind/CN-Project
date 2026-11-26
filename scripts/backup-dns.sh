#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "$0")/.." && pwd)"
CONF="$ROOT/configs/dns/dnsmasq-backup.conf"
PID_FILE="$ROOT/var/run/dnsmasq-backup.pid"
# Homebrew must not be invoked as root. Override this path on Intel Macs with
# DNSMASQ_BIN=/usr/local/opt/dnsmasq/sbin/dnsmasq if using this script there.
DNSMASQ="${DNSMASQ_BIN:-/opt/homebrew/opt/dnsmasq/sbin/dnsmasq}"

config_test() {
    "$DNSMASQ" --test --conf-file="$CONF"
}

verified_pid() {
    [[ -r "$PID_FILE" ]] || return 1
    local pid
    pid="$(<"$PID_FILE")"
    kill -0 "$pid" 2>/dev/null &&
        ps -p "$pid" -o command= | grep -Fq -- "--conf-file=$CONF" || return 1
    printf '%s\n' "$pid"
}

require_root() {
    if [[ "$(id -u)" -ne 0 ]]; then
        printf 'This operation needs administrator privileges for port 53. After approval run: sudo %s %s\n' \
            "$0" "$1" >&2
        exit 1
    fi
}

case "${1:-}" in
    config-test)
        mkdir -p "$ROOT/var/run" "$ROOT/var/log"
        config_test
        ;;
    start)
        require_root start
        mkdir -p "$ROOT/var/run" "$ROOT/var/log"
        config_test
        if pid="$(verified_pid)"; then
            printf 'Project backup dnsmasq already running (pid %s)\n' "$pid"
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
        if lsof -nP -iTCP:53 -sTCP:LISTEN 2>/dev/null | tail -n +2 | grep -q . ||
           lsof -nP -iUDP:53 2>/dev/null | tail -n +2 | grep -q .; then
            printf 'Port 53 is already in use; refusing to replace the existing DNS service.\n' >&2
            exit 1
        fi
        "$DNSMASQ" --conf-file="$CONF"
        for ((attempt = 0; attempt < 30; attempt++)); do
            if pid="$(verified_pid)" &&
                [[ "$(dig +time=1 +tries=1 +short @127.0.0.1 app.team1.test A 2>/dev/null)" == "10.7.26.113" ]] &&
                [[ "$(dig +time=1 +tries=1 +short @10.7.26.113 api.team1.test A 2>/dev/null)" == "10.7.26.113" ]]; then
                printf 'Project backup dnsmasq ready on 127.0.0.1:53 and 10.7.26.113:53 (pid %s)\n' "$pid"
                exit 0
            fi
            sleep 0.2
        done
        printf 'Backup dnsmasq did not pass local/LAN checks; inspect %s and %s\n' \
            "$ROOT/var/log/dnsmasq-backup.log" "$ROOT/var/run/dnsmasq-backup.pid" >&2
        exit 1
        ;;
    status)
        pid="$(verified_pid)" || { printf 'Project backup dnsmasq is not running.\n' >&2; exit 1; }
        printf 'Project backup dnsmasq process: pid %s\n' "$pid"
        for address in 127.0.0.1 10.7.26.113; do
            printf '\nDNS A answers from %s:\n' "$address"
            dig +time=2 +tries=1 +noall +answer @"$address" app.team1.test A
            dig +time=2 +tries=1 +noall +answer @"$address" api.team1.test A
        done
        ;;
    stop)
        require_root stop
        if ! pid="$(verified_pid)"; then
            printf 'No verified project backup dnsmasq process to stop.\n'
            exit 0
        fi
        kill -TERM "$pid"
        for ((attempt = 0; attempt < 50; attempt++)); do
            if ! kill -0 "$pid" 2>/dev/null; then
                rm -f "$PID_FILE"
                printf 'Project backup dnsmasq stopped (pid %s)\n' "$pid"
                exit 0
            fi
            sleep 0.1
        done
        printf 'Backup dnsmasq did not stop; inspect pid %s\n' "$pid" >&2
        exit 1
        ;;
    reload)
        require_root reload
        pid="$(verified_pid)" || { printf 'No verified project backup dnsmasq process to reload.\n' >&2; exit 1; }
        kill -HUP "$pid"
        printf 'Sent SIGHUP to dnsmasq (hosts/cache reload only). Restart to apply config changes.\n'
        ;;
    *)
        printf 'Usage: %s {config-test|start|status|stop|reload}\n' "$0" >&2
        exit 2
        ;;
esac
