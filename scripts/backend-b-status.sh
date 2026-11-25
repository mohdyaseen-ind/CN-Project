#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "$0")/.." && pwd)"
PID_FILE="$ROOT/var/run/backend-b.pid"

if [[ ! -f "$PID_FILE" ]]; then
    printf 'Backend B is not tracked as running by this project\n' >&2
    exit 1
fi

pid="$(<"$PID_FILE")"
if ! kill -0 "$pid" 2>/dev/null ||
    ! ps -p "$pid" -o command= | grep -Fq "$ROOT/backend/server.py B 3002"; then
    printf 'Backend B PID file is stale or does not identify Backend B\n' >&2
    exit 1
fi

printf 'Backend B process: pid %s\n' "$pid"
curl --silent --show-error --fail --include --max-time 3 \
    http://127.0.0.1:3002/api/status
