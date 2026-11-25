#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "$0")/.." && pwd)"
PID_FILE="$ROOT/var/run/backend-a.pid"

if [[ ! -f "$PID_FILE" ]]; then
    printf 'Backend A PID file not found; no project-managed process to stop\n'
    exit 0
fi

pid="$(<"$PID_FILE")"
if ! kill -0 "$pid" 2>/dev/null; then
    rm -f "$PID_FILE"
    printf 'Removed stale Backend A PID file\n'
    exit 0
fi
if ! ps -p "$pid" -o command= | grep -Fq "$ROOT/backend/server.py A 3001"; then
    printf 'Refusing to signal unrelated process %s\n' "$pid" >&2
    exit 1
fi

kill -TERM "$pid"
for ((attempt = 0; attempt < 50; attempt++)); do
    if ! kill -0 "$pid" 2>/dev/null; then
        rm -f "$PID_FILE"
        printf 'Backend A stopped (pid %s)\n' "$pid"
        exit 0
    fi
    sleep 0.1
done

printf 'Backend A did not stop after SIGTERM; inspect pid %s and %s\n' \
    "$pid" "$ROOT/var/log/backend-a.log" >&2
exit 1
