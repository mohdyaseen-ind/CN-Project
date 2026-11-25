#!/usr/bin/env bash
set -euo pipefail

if [[ "$(id -u)" -ne 0 ]]; then
    printf 'Run only after approval with sudo: %s\n' "$0" >&2
    exit 1
fi

ROOT="$(cd -- "$(dirname -- "$0")/.." && pwd)"
ANCHOR="com.apple/cnproject/backend-b"
BACKUP_DIR="$ROOT/var/pf-backups"
STAMP="$(date '+%Y%m%d-%H%M%S')"
RULES_FILE="$BACKUP_DIR/backend-b-anchor-$STAMP.rules"
INFO_FILE="$BACKUP_DIR/backend-b-pf-info-$STAMP.txt"

mkdir -p "$BACKUP_DIR"
chmod 755 "$BACKUP_DIR"
/sbin/pfctl -a "$ANCHOR" -sr >"$RULES_FILE"
/sbin/pfctl -s info >"$INFO_FILE"
chmod 644 "$RULES_FILE" "$INFO_FILE"
printf 'Saved current anchor rules: %s\nSaved PF status: %s\n' "$RULES_FILE" "$INFO_FILE"
