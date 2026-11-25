#!/usr/bin/env bash
set -u

EDGE_IP="${EDGE_IP:-10.7.26.113}"
DNS_PRIMARY="${DNS_PRIMARY:-10.7.28.39}"
DNS_BACKUP="${DNS_BACKUP:-10.7.18.197}"
domains=(app.team1.test api.team1.test)
overall_rc=0

run() {
    printf '\n$'
    printf ' %q' "$@"
    printf '\n'
    "$@"
    local rc=$?
    printf '[exit %s]\n' "$rc"
    if [[ "$rc" -ne 0 ]]; then
        overall_rc=1
    fi
}

printf 'Edge diagnostic at %s\n' "$(date -Iseconds 2>/dev/null || date)"
for dns in "$DNS_PRIMARY" "$DNS_BACKUP"; do
    for domain in "${domains[@]}"; do
        run dig +time=2 +tries=1 +noall +answer @"$dns" "$domain" A
    done
done

for endpoint in "$DNS_PRIMARY:3001" "$DNS_BACKUP:3002" "$EDGE_IP:8080" "$EDGE_IP:8443"; do
    host="${endpoint%:*}"
    port="${endpoint##*:}"
    run nc -vz -G 2 "$host" "$port"
done

for domain in "${domains[@]}"; do
    run curl --silent --show-error --max-time 5 --resolve "$domain:8443:$EDGE_IP" \
        --cacert "$(cd -- "$(dirname -- "$0")/.." && pwd)/edge/certs/app.crt" \
        --include "https://$domain:8443/api/status"
done

exit "$overall_rc"
