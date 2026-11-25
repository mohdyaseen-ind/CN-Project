#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "$0")/.." && pwd)"
STATE_DIR="$ROOT/var/run"
LOG_DIR="$ROOT/var/log"
PID_FILE="$STATE_DIR/backend-b.pid"
LOG_FILE="$LOG_DIR/backend-b.log"

mkdir -p "$STATE_DIR" "$LOG_DIR"

is_backend_b() {
    local pid="$1"
    kill -0 "$pid" 2>/dev/null &&
        ps -p "$pid" -o command= | grep -Fq "$ROOT/backend/server.py B 3002"
}

if [[ -f "$PID_FILE" ]]; then
    pid="$(<"$PID_FILE")"
    if is_backend_b "$pid"; then
        printf 'Backend B already running (pid %s)\n' "$pid"
        exit 0
    fi
    if kill -0 "$pid" 2>/dev/null; then
        printf 'Refusing to use PID file for unrelated live process %s\n' "$pid" >&2
        exit 1
    fi
    rm -f "$PID_FILE"
fi

python3 "$ROOT/backend/server.py" B 3002 >>"$LOG_FILE" 2>&1 </dev/null &
pid=$!
printf '%s\n' "$pid" >"$PID_FILE"

for ((attempt = 0; attempt < 30; attempt++)); do
    if ! is_backend_b "$pid"; then
        printf 'Backend B exited during startup; see %s\n' "$LOG_FILE" >&2
        rm -f "$PID_FILE"
        exit 1
    fi
    if curl --silent --fail --max-time 1 \
        http://127.0.0.1:3002/api/status >/dev/null; then
        printf 'Backend B ready at 0.0.0.0:3002 (pid %s)\n' "$pid"
        exit 0
    fi
    sleep 0.2
done

printf 'Backend B did not become ready; see %s\n' "$LOG_FILE" >&2
exit 1
