# Sankalp Phase 2 Evidence Index

Actual terminal output is kept in `logs/`. No screenshots are synthesized.
Several original Phase 1 screenshots are retained in `evidence/`, but the
reviewed DNS/LB/TLS/failure images predate the current `:8080/:8443` edge and
are not used as proof of this current integration. The existing DNS capture
shows a query to public `8.8.8.8` that returned NXDOMAIN for the project name.

| # | Required screenshot | Status | Actual result / evidence |
|---:|---|---|---|
| 01 | `01-network-ip-and-ping.png` | PASS, screenshot pending | `logs/08-host-and-peer-checks.txt`: `10.7.26.113`, `/19`, gateway, both peer pings passed. |
| 02 | `02-primary-dns.png` | PASS in logs; screenshot needs provenance check | `logs/09-dns-remote-verification.txt` verifies primary UDP/TCP answers, TTL 30, forwarding. `09-sankalp-primary-dns-test.png` is present, but its heading says “FROM SARTHAK” while the terminal prompt shows Sankalp; re-capture with a correct label before using it as final evidence. |
| 03 | `03-backup-dns.png` | PENDING, no screenshot | Sankalp's replacement backup resolver is not started yet; the earlier Sarthak-hosted DNS failure is historical in `logs/09-dns-remote-verification.txt`. |
| 04 | `04-backend-a.png` | PASS, screenshot pending | `logs/06-baseline-integration.txt`: remote Backend A HTTP 200, `X-Backend: A`. |
| 05 | `05-backend-b.png` | PASS, screenshot pending | `logs/06-baseline-integration.txt`: remote Backend B HTTP 200, `X-Backend: B`. |
| 06 | `06-nginx-config-validation.png` | PASS, screenshot pending | `logs/06-baseline-integration.txt`: project config syntax/test successful. |
| 07 | `07-https-success.png` | PASS with explicit local CA, screenshot pending | `logs/07-additional-verification.txt`: both domain SANs/hostname verified; no system/browser trust installed. |
| 08 | `08-load-balancing.png` | PASS, screenshot pending | `logs/06-baseline-integration.txt`: six alternating A/B responses and `X-Edge: primary`. |
| 09 | `09-cache-control.png` | PASS, screenshot pending | `logs/06-baseline-integration.txt`: `Cache-Control: max-age=60` and ETag. |
| 10 | `10-http-304.png` | PASS, screenshot pending | `logs/06-baseline-integration.txt`: matching ETag returned HTTP 304. |
| 11 | `11-primary-dns-stopped.png` | NOT RUN | Requires explicit coordination with Prateek and backup DNS verification. |
| 12 | `12-backup-dns-failover.png` | PENDING | Run only after the Sankalp resolver starts and both clients pass remote UDP/TCP queries; keep Prateek primary online until then. |
| 13 | `13-primary-dns-restored.png` | NOT RUN | Primary DNS was never stopped. |
| 14 | `14-dns-ttl-before.png` | PARTIAL | Primary direct answer shows 30 seconds; no client cache established. |
| 15 | `15-dns-ttl-after.png` | NOT RUN | Requires coordinated record change on both resolvers and client cache evidence. |
| 16 | `16-dns-cache-flush.png` | NOT RUN | Requires a client-side cache test and explicit restoration. |
| 17 | `17-firewall-rules-active.png` | NOT RUN | PF isolation rules are not activated; macOS Application Firewall status is separate. |
| 18 | `18-edge-backend-access-success.png` | PASS, screenshot pending | Both upstream status endpoints return 200 through local edge; `logs/06-baseline-integration.txt`. |
| 19 | `19-direct-backend-access-blocked.png` | NOT RUN | Requires an approved active isolation policy and unauthorized client test. |
| 20 | `20-backend-a-stopped.png` | NOT RUN | Requires READY from team; Backend A remains running. |
| 21 | `21-backend-b-failover.png` | NOT RUN | Requires coordinated Backend A stop. |
| 22 | `22-backend-a-recovered.png` | NOT RUN | Backend A remains running; no failure cycle initiated. |
| 23 | `23-both-backends-down.png` | NOT RUN | Requires coordinated outage authorization; do not run unilaterally. |
| 24 | `24-primary-edge.png` | PASS, screenshot pending | `X-Edge: primary`, HTTP/2 and HTTPS on the running project edge. |
| 25 | `25-standby-edge-migration.png` | BLOCKED | Remote standby HTTPS reset; no DNS change attempted. |
| 26 | `26-troubleshooting.png` | PREPARED | `scripts/diagnose-edge.sh` exists; controlled practice fault/retest not run. |
| 27 | `27-final-system-verification.png` | PENDING | Wait for backup DNS, trust, standby and coordinated extension checks. |
| 28 | `28-backup-dns-config-validation.png` | PASS, screenshot pending | `logs/17-backup-dns-config-test.txt`: dnsmasq syntax check OK. |
| 29 | `29-backup-dns-port-firewall-audit.png` | PASS, screenshot pending | `logs/18-backup-dns-prestart-audit.txt`: dnsmasq 2.93 installed, TCP/UDP 53 free, app firewall allows dnsmasq; service not running. |
| 30 | `30-backup-dns-local-lan-resolution.png` | PENDING | Requires admin-authorized project dnsmasq start; verify both loopback and `10.7.26.113`. |
| 31 | `31-backup-dns-remote-prateek.png` | PENDING | Prateek must run remote UDP/TCP verification commands in `docs/phase2/sarthak-client-setup.md`. |
| 32 | `32-backup-dns-remote-sarthak.png` | PENDING | Sarthak must run remote UDP/TCP verification commands in `docs/phase2/sarthak-client-setup.md`. |

## Screenshot capture commands

Run the corresponding test first. When its real output is visible in Terminal,
run the exact command for that screenshot and select the terminal region. Do not
capture a pending or blocked test as if it passed.

```sh
screencapture -i evidence/phase2/sankalp/01-network-ip-and-ping.png
screencapture -i evidence/phase2/sankalp/02-primary-dns.png
screencapture -i evidence/phase2/sankalp/03-backup-dns.png
screencapture -i evidence/phase2/sankalp/04-backend-a.png
screencapture -i evidence/phase2/sankalp/05-backend-b.png
screencapture -i evidence/phase2/sankalp/06-nginx-config-validation.png
screencapture -i evidence/phase2/sankalp/07-https-success.png
screencapture -i evidence/phase2/sankalp/08-load-balancing.png
screencapture -i evidence/phase2/sankalp/09-cache-control.png
screencapture -i evidence/phase2/sankalp/10-http-304.png
screencapture -i evidence/phase2/sankalp/11-primary-dns-stopped.png
screencapture -i evidence/phase2/sankalp/12-backup-dns-failover.png
screencapture -i evidence/phase2/sankalp/13-primary-dns-restored.png
screencapture -i evidence/phase2/sankalp/14-dns-ttl-before.png
screencapture -i evidence/phase2/sankalp/15-dns-ttl-after.png
screencapture -i evidence/phase2/sankalp/16-dns-cache-flush.png
screencapture -i evidence/phase2/sankalp/17-firewall-rules-active.png
screencapture -i evidence/phase2/sankalp/18-edge-backend-access-success.png
screencapture -i evidence/phase2/sankalp/19-direct-backend-access-blocked.png
screencapture -i evidence/phase2/sankalp/20-backend-a-stopped.png
screencapture -i evidence/phase2/sankalp/21-backend-b-failover.png
screencapture -i evidence/phase2/sankalp/22-backend-a-recovered.png
screencapture -i evidence/phase2/sankalp/23-both-backends-down.png
screencapture -i evidence/phase2/sankalp/24-primary-edge.png
screencapture -i evidence/phase2/sankalp/25-standby-edge-migration.png
screencapture -i evidence/phase2/sankalp/26-troubleshooting.png
screencapture -i evidence/phase2/sankalp/27-final-system-verification.png
screencapture -i evidence/phase2/sankalp/28-backup-dns-config-validation.png
screencapture -i evidence/phase2/sankalp/29-backup-dns-port-firewall-audit.png
screencapture -i evidence/phase2/sankalp/30-backup-dns-local-lan-resolution.png
screencapture -i evidence/phase2/sankalp/31-backup-dns-remote-prateek.png
screencapture -i evidence/phase2/sankalp/32-backup-dns-remote-sarthak.png
```

Keep public certificates separate from private keys. Do not copy any `.key`
file into evidence or the submission bundle.
