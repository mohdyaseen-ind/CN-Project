#!/usr/bin/env bash
set -euo pipefail

if [[ "$(id -u)" -ne 0 ]]; then
    printf 'Run only after approval with sudo -A: %s BACKUP_RULES_FILE\n' "$0" >&2
    exit 1
fi
if [[ "$#" -ne 1 ]]; then
    printf 'Usage: %s var/pf-backups/BACKUP_RULES_FILE\n' "$0" >&2
    exit 2
fi

ROOT="$(cd -- "$(dirname -- "$0")/.." && pwd)"
ANCHOR="com.apple/cnproject/backend-a"
BACKUP_FILE="$1"

case "$BACKUP_FILE" in
    "$ROOT"/var/pf-backups/*) ;;
    *) printf 'Refusing backup outside %s/var/pf-backups\n' "$ROOT" >&2; exit 1 ;;
esac
if [[ ! -f "$BACKUP_FILE" ]]; then
    printf 'Backup rules file not found: %s\n' "$BACKUP_FILE" >&2
    exit 1
fi

if [[ -s "$BACKUP_FILE" ]]; then
    /sbin/pfctl -a "$ANCHOR" -f "$BACKUP_FILE"
else
    /sbin/pfctl -a "$ANCHOR" -F rules
fi
printf 'Restored prior Backend A anchor rules from %s\n' "$BACKUP_FILE"
