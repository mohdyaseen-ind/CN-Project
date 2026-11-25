# Sankalp Phase 2 Evidence Index

Evidence must be captured from real commands, browser sessions, or packet
captures. The PNGs below have not been captured yet; no screenshots are
fabricated. Actual command outputs and timestamps belong in `logs/`.

## Required screenshots

| # | File | Status / capture guidance |
|---:|---|---|
| 01 | `01-lan-connectivity.png` | Pending peer reachability; capture terminal after `ifconfig en0`, `route -n get default`, and peer pings from a normal terminal. |
| 02 | `02-dns-resolution.png` | Pending both DNS servers; capture `dig @10.7.28.39 app.team1.test A` and `dig @10.7.18.197 app.team1.test A`. |
| 03 | `03-nginx-config-validation.png` | Pending nginx install; capture `./scripts/edge-nginx.sh config-test`. |
| 04 | `04-nginx-service-status.png` | Pending nginx install/start; capture `./scripts/edge-nginx.sh status`. |
| 05 | `05-https-browser.png` | Pending client trust and edge; show `https://app.team1.test:8443/api/status` with no certificate warning. |
| 06 | `06-tls-certificate-validation.png` | Pending edge; capture `openssl s_client`/`openssl x509` output for both SAN names. |
| 07 | `07-http-https-redirect.png` | Pending edge; capture `curl -I http://app.team1.test:8080/api/status`. |
| 08 | `08-load-balancing.png` | Pending both backends; show repeated response headers with both backend identities. |
| 09 | `09-cache-control.png` | Pending integrated service; capture catalog response headers. |
| 10 | `10-etag-304.png` | Pending integrated service; capture initial ETag and conditional `304`. |
| 11 | `11-backup-dns-failover.png` | Pending coordinated backup DNS test and system resolver verification. |
| 12 | `12-dns-ttl.png` | Pending cache-aware resolver TTL/expiry test and cache flush. |
| 13 | `13-backend-isolation.png` | Pending approved source/destination isolation checks. |
| 14 | `14-backend-a-failure.png` | Pending coordinated Backend A stop; capture failure/retry evidence. |
| 15 | `15-backend-b-serving.png` | Pending same coordinated test; capture successful Backend B response. |
| 16 | `16-backend-a-recovery.png` | Pending Backend A restart; capture both identities after recovery. |
| 17 | `17-both-backends-down-502.png` | Pending explicit team authorization for outage; capture 502 and restore both. |
| 18 | `18-edge-migration-primary.png` | Pending migration; capture baseline primary `X-Edge`. |
| 19 | `19-edge-migration-standby.png` | Pending coordinated DNS cutover; capture standby `X-Edge`, then restore DNS. |
| 20 | `20-troubleshooting.png` | Pending controlled practice fault, diagnosis, repair, and verification. |
| 21 | `21-final-system-verification.png` | Pending all final checks and team evidence. |

## Logs

`logs/` contains audit output and future timestamped command transcripts. Store
configuration snapshots and packet captures here or in clearly named sibling
directories. Keep private keys out of evidence and Git; public certs may be
shared only after confirming they contain no private key material.

To capture a real terminal screenshot on macOS after the applicable command
output is visible, use `screencapture -i evidence/phase2/sankalp/NN-name.png`.
For browser evidence, first open the page and verify the browser shows a trusted
certificate, then capture the selected window with `screencapture -i`.
