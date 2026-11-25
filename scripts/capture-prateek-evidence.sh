#!/usr/bin/env bash

set -u

ROOT="$(cd -- "$(dirname -- "$0")/.." && pwd)"
EVIDENCE="$ROOT/evidence/phase2/prateek"
cd "$ROOT" || exit 1

if [[ ! -t 0 || ! -t 1 ]]; then
    printf 'Run this script from an interactive macOS Terminal window.\n' >&2
    exit 2
fi

run_check() {
    "$@"
    local result=$?
    printf '[command exit: %s]\n' "$result"
    return 0
}

show_network() {
    printf '%s\n' '--- en0 ---'
    run_check ipconfig getifaddr en0
    printf '%s\n' '--- default route ---'
    route -n get default | grep -E 'gateway:|interface:'
    printf '[command exit: %s]\n' "$?"
    printf '%s\n' '--- Sankalp ping ---'
    run_check ping -c 2 -W 1000 10.7.26.113
    printf '%s\n' '--- Sarthak ping ---'
    run_check ping -c 2 -W 1000 10.7.18.197
}

show_primary_dns() {
    printf '%s\n' '--- dnsmasq process ---'
    ps -ax -o pid=,command= | grep '[d]nsmasq'
    printf '[command exit: %s]\n' "$?"
    printf '%s\n' '--- TCP/UDP port 53 listeners ---'
    netstat -anv -p tcp | grep -E '[.:]53[[:space:]]'
    printf '[command exit: %s]\n' "$?"
    netstat -anv -p udp | grep -E '[.:]53[[:space:]]'
    printf '[command exit: %s]\n' "$?"
    printf '%s\n' '--- UDP DNS answers and TTL ---'
    run_check dig +time=2 +tries=1 +noall +answer @10.7.28.39 app.team1.test A
    run_check dig +time=2 +tries=1 +noall +answer @10.7.28.39 api.team1.test A
    printf '%s\n' '--- TCP DNS answers ---'
    run_check dig +tcp +time=2 +tries=1 +noall +answer @10.7.28.39 app.team1.test A
    run_check dig +tcp +time=2 +tries=1 +noall +answer @10.7.28.39 api.team1.test A
}

show_backup_dns() {
    printf '%s\n' '--- backup DNS UDP result ---'
    run_check dig +time=2 +tries=1 +comments +stats @10.7.18.197 app.team1.test A
    printf '%s\n' '--- backup DNS TCP result ---'
    run_check dig +tcp +time=2 +tries=1 +comments +stats @10.7.18.197 app.team1.test A
}

show_backend_a() {
    run_check ./scripts/backend-a-status.sh
}

show_backend_b() {
    run_check curl --noproxy '*' --silent --show-error --include --max-time 6 \
        http://10.7.18.197:3002/api/status
}

show_cache() {
    printf '%s\n' '--- catalog Cache-Control and ETag ---'
    run_check curl --noproxy '*' --silent --show-error --include --max-time 5 \
        http://127.0.0.1:3001/api/catalog
    printf '%s\n' '--- conditional request using the returned ETag ---'
    show_conditional_304
}

show_conditional_304() {
    local etag
    etag="$(curl --noproxy '*' --silent --show-error --dump-header - \
        --output /dev/null --max-time 5 http://127.0.0.1:3001/api/catalog |
        awk 'tolower($1)=="etag:" {gsub("\r", ""); print $2; exit}')"
    if [[ -z "$etag" ]]; then
        printf 'No ETag received; conditional request was not sent.\n'
        return 0
    fi
    printf 'Using actual ETag: %s\n' "$etag"
    run_check curl --noproxy '*' --silent --show-error --include --max-time 5 \
        -H "If-None-Match: $etag" http://127.0.0.1:3001/api/catalog
}

show_nginx_config() {
    printf '%s\n' '--- standby nginx syntax test ---'
    run_check ./scripts/standby-nginx.sh config-test
    printf '%s\n' '--- main-edge nginx syntax test; does not start nginx ---'
    run_check ./scripts/edge-nginx.sh config-test
}

show_standby_https() {
    run_check ./scripts/standby-nginx.sh status
}

show_standby_distribution() {
    printf '%s\n' 'Current probe only: do not claim load balancing unless both A and B appear.'
    local request
    for request in 1 2 3 4 5 6; do
        printf '%s\n' "--- request $request ---"
        run_check curl --noproxy '*' --silent --show-error --dump-header - \
            --output /dev/null --max-time 8 --cacert edge/certs/ca.crt \
            --resolve app.team1.test:8443:127.0.0.1 \
            https://app.team1.test:8443/api/status
    done
}

show_ttl() {
    printf '%s\n' '--- current primary authoritative TTL; no records changed ---'
    run_check dig +time=2 +tries=1 +noall +answer @10.7.28.39 app.team1.test A
    run_check dig +time=2 +tries=1 +noall +answer @10.7.28.39 api.team1.test A
}

show_main_edge() {
    printf '%s\n' '--- HTTP redirect ---'
    run_check curl --noproxy '*' --silent --show-error --include --max-time 6 \
        --resolve app.team1.test:8080:10.7.26.113 http://app.team1.test:8080/
    printf '%s\n' '--- HTTPS verification with the current local CA; failure is retained ---'
    run_check curl --noproxy '*' --silent --show-error --include --max-time 6 \
        --cacert edge/certs/ca.crt \
        --resolve app.team1.test:8443:10.7.26.113 \
        https://app.team1.test:8443/api/status
}

capture() {
    local title="$1"
    local filename="$2"
    local display_function="$3"
    shift 3

    printf '\n========== %s ==========\n' "$title"
    "$display_function"
    printf '\nOutput above is the actual result. Select the Terminal output region.\n'
    read -r -p 'Press Return to open interactive screenshot capture (Esc skips): '

    local destination="$EVIDENCE/$filename"
    if [[ -e "$destination" ]]; then
        printf 'Preserving existing file; skipped capture: %s\n' "$destination"
        return 0
    fi
    /usr/sbin/screencapture -i "$destination"
    if [[ -s "$destination" ]]; then
        printf 'Saved PNG: %s\n' "$destination"
        local alias
        for alias in "$@"; do
            if [[ ! -e "$EVIDENCE/$alias" ]]; then
                cp -p "$destination" "$EVIDENCE/$alias"
                printf 'Saved same captured output under checklist alias: %s\n' "$EVIDENCE/$alias"
            else
                printf 'Preserving existing file; skipped alias: %s\n' "$EVIDENCE/$alias"
            fi
        done
    else
        printf 'No screenshot saved for %s.\n' "$filename"
    fi
}

mkdir -p "$EVIDENCE"

capture 'Prateek interface and peer reachability' \
    '01-network-ip-and-ping.png' show_network
capture 'Primary DNS answers, TTL, and service listeners' \
    '02-primary-dns.png' show_primary_dns \
    '01-primary-dns.png' '02-primary-dns-service.png'
capture 'Backup DNS current remote probe; failures remain failures' \
    '03-backup-dns.png' show_backup_dns
capture 'Backend A current status' \
    '04-backend-a.png' show_backend_a '03-backend-a-status.png'
capture 'Backend B current direct status; failures remain failures' \
    '05-backend-b.png' show_backend_b
capture 'Standby and main-edge configuration syntax checks' \
    '06-nginx-config-validation.png' show_nginx_config
capture 'Standby HTTPS status' \
    '07-https-success.png' show_standby_https
capture 'Current standby distribution; only claim what the headers show' \
    '08-load-balancing.png' show_standby_distribution
capture 'Backend A catalog cache headers' \
    '09-cache-control.png' show_cache '04-backend-a-cache-304.png'
capture 'Backend A conditional request result' \
    '10-http-304.png' show_conditional_304
capture 'Primary DNS TTL before any coordinated mutation' \
    '14-dns-ttl-before.png' show_ttl
capture 'Main-edge redirect and current TLS verification result' \
    '24-primary-edge.png' show_main_edge

printf '\nCapture sequence finished. Review each PNG and update the evidence index with actual outcomes.\n'
