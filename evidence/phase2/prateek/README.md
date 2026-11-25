# Prateek Phase 2 Evidence Index

Command output is saved under `logs/` only after the command actually runs.
At the 00:04 IST audit, this directory contained **6 PNG screenshots**:
`13-backend-a-restored.png` (startup only; not proof of recovery) and
`14-standby-nginx.png` (previously verified local standby response), plus four
supplemental current Terminal screenshots listed below.

Run the grouped, non-disruptive verification and interactive capture sequence
from the repository root in macOS Terminal:

```sh
./scripts/capture-prateek-evidence.sh
```

The script displays each real command result and pauses for interactive
`screencapture -i`. It preserves existing PNGs and does not run coordinated
failure, DNS mutation, PF activation, or edge migration tests. The latest
interactive run reported `could not create image from rect`, so it saved no
screenshots itself. Four actual Terminal screenshots supplied by Prateek have
been copied unchanged below; they show the command results and the capture
error. If a probe fails, record it as a failure, not a pass.

| Requested screenshot | Evidence/test | Status |
|---|---|---|
| `01-primary-dns.png` | Direct DNS answers and TTL | UDP/TCP answers and TTL 30 rerun in `25-current-evidence-rerun.txt`; screenshot absent |
| `02-primary-dns-service.png` | dnsmasq TCP/UDP listeners and process | Process/listeners confirmed by `netstat`; screenshot absent |
| `03-backend-a-status.png` | Backend A `/api/status`, HTTP 200, identity header | Current HTTP 200 and `X-Backend: A`; screenshot absent |
| `04-backend-a-cache-304.png` | Catalog ETag/Cache-Control and conditional 304 | Current cache headers and conditional HTTP 304; screenshot absent |
| `05-primary-dns-stopped.png` | Coordinated primary DNS stop | Not run; Sarthak confirmation required |
| `06-primary-dns-restored.png` | Coordinated primary DNS restoration | Not run; primary DNS remains running |
| `07-dns-ttl-before.png` | Before-change DNS answer/TTL | Primary TTL query log available; coordinated mutation pending |
| `08-dns-ttl-after.png` | TTL/cache expiry after both records change | Not run; both DNS operators/client required |
| `09-firewall-rules.png` | Prepared rules and active anchor | Rules prepared; not active; admin check required |
| `10-edge-access-success.png` | Main-edge HTTPS from authorized client | Do not claim success: HTTP redirects, but current HTTPS verification fails (curl error 60) |
| `11-direct-access-blocked.png` | Unauthorized direct Backend A connection blocked | Not run; firewall activation and client required |
| `12-backend-a-stopped.png` | Backend A outage | Not run; Sankalp coordination required |
| `13-backend-a-restored.png` | Backend A start/ready | Present; start script reports ready at `0.0.0.0:3001` (PID 64666); no preceding failure, so this does not prove HA recovery |
| `14-standby-nginx.png` | Standby config test and local HTTPS response | Present; earlier screenshot shows successful config test and HTTP 200 with `X-Backend: A` and `X-Edge: standby`; latest six-request rerun returned only A |
| `15-edge-migration.png` | Coordinated DNS cutover to standby and `X-Edge` | Not run; team validation/approval required |
| `16-rollback-verification.png` | DNS/firewall rollback and service verification | Not run; no migration/firewall change made |

Capture a screenshot only after the corresponding command/test has actually
run. A failed result may be captured as a failure, never as a pass. For pending
coordinated tests, leave the PNG absent until the team performs the test.

### Supplemental current Terminal screenshots

| PNG | Contents |
|---|---|
| `25-current-terminal-rerun-01.png` | Backup DNS TCP reset; Backend A HTTP 200; Backend B empty reply; nginx config tests pass |
| `25-current-terminal-rerun-02.png` | Standby HTTPS 200 with `X-Backend: A` and `X-Edge: standby`; current load-distribution output |
| `25-current-terminal-rerun-03.png` | Additional all-A requests and catalog Cache-Control/ETag plus conditional 304 |
| `25-current-terminal-rerun-04.png` | Conditional 304, TTL 30 answers, main-edge HTTP 301, and TLS verification failure |

These are real screenshots of Terminal output. They include the failed
interactive region-capture messages and do not claim that those attempts saved
the requested per-test images.

Exact-name count across both indexes below: 43 PNG filenames are requested;
2 files match requested names and 41 exact requested filenames are absent. The
four supplemental images increase the actual PNG count to 6 but do not use
those checklist names. One existing file (`13-backend-a-restored.png`) is only
startup evidence, not recovery evidence. The existing standby screenshot
semantically covers local HTTPS, but it does not have the final-checklist
filename `07-https-success.png`.

Available actual logs: `00-peer-reachability.txt`, `01-primary-dns.txt`,
`02-primary-dns-service.txt`, `03-backend-a-status.txt`,
`04-backend-a-cache-304.txt`, `09-pf-rules-review.txt`, and
`14-standby-nginx.txt`. Follow-up integration logs: `15-current-integration-audit.txt`,
`16-current-backend-integration.txt`, `17-current-edge-integration.txt`,
`18-network-ping.txt`, `19-main-edge-config-test.txt`, and
`20-main-edge-config-test-fixed.txt`, `21-nginx-binary-runtime-version.txt`.
Main-edge live test outputs are in `22-main-edge-first-check.txt`,
`23-main-edge-load-balancing.txt`, and
`24-main-edge-cert-fingerprint.txt`. Latest actual command reruns, including
the current Backend B empty reply, all-A standby responses, and main-edge TLS
verification failure, are in `25-current-evidence-rerun.txt`.

## Final Shared Evidence Checklist — Prateek Scope

The shared final checklist uses these 27 filenames. Capture only items relevant
to Prateek and only after the displayed test actually runs. The existing
`14-standby-nginx.png` is retained as valid standby evidence; it is not copied
or renamed to a different test filename.

| Required filename | Current result | Evidence / dependency |
|---|---|---|
| `01-network-ip-and-ping.png` | Screenshot absent | Current ping: Sankalp 2/2; Sarthak 0/2; see `25-current-evidence-rerun.txt` |
| `02-primary-dns.png` | Screenshot absent | Current direct UDP/TCP answers and TTL 30 in `25-current-evidence-rerun.txt` |
| `03-backup-dns.png` | Screenshot absent; current test fails | UDP timeout, TCP reset; Sarthak/admin follow-up required |
| `04-backend-a.png` | Screenshot absent | Current HTTP 200 and `X-Backend: A` |
| `05-backend-b.png` | Screenshot absent; current test fails | Latest direct curl returned empty reply; earlier 200 is historical only |
| `06-nginx-config-validation.png` | Screenshot absent | Current standby and main config syntax checks pass on Prateek |
| `07-https-success.png` | Screenshot absent under this name | Existing `14-standby-nginx.png` is historical verified local standby HTTPS; main-edge trust is pending |
| `08-load-balancing.png` | Screenshot absent; current test does not pass | Six latest standby requests returned A only; earlier A/B alternation is historical |
| `09-cache-control.png` | Screenshot absent | Current catalog response includes Cache-Control and ETag |
| `10-http-304.png` | Screenshot absent | Current conditional request returned HTTP 304 |
| `11-primary-dns-stopped.png` | NOT RUN | Requires coordinated DNS failover window |
| `12-backup-dns-failover.png` | BLOCKED | Backup DNS is not answering remotely from Prateek |
| `13-primary-dns-restored.png` | NOT RUN | Primary DNS was never stopped and remains running |
| `14-dns-ttl-before.png` | Screenshot absent; partial test | Current authority TTL 30; client-side cached result not demonstrated |
| `15-dns-ttl-after.png` | NOT RUN | Requires both DNS operators and client |
| `16-dns-cache-flush.png` | NOT RUN | Requires agreed TTL/cache test |
| `17-firewall-rules-active.png` | NOT RUN | Rules are prepared only; admin/team approval required |
| `18-edge-backend-access-success.png` | Screenshot absent; partial/current failure | Standby reaches Backend A; current direct Backend B probe is empty reply; main-edge TLS remains untrusted |
| `19-direct-backend-access-blocked.png` | NOT RUN | PF isolation not activated |
| `20-backend-a-stopped.png` | NOT RUN | Requires Sankalp confirmation and coordinated HA test |
| `21-backend-b-failover.png` | NOT RUN | Requires coordinated HA test |
| `22-backend-a-recovered.png` | NOT RUN | Backend A remains running |
| `23-both-backends-down.png` | NOT RUN | Requires coordinated failure test |
| `24-primary-edge.png` | Screenshot absent; HTTPS blocked | HTTP 301 works; HTTPS fails certificate verification (curl error 60) |
| `25-standby-edge-migration.png` | NOT RUN | Requires both DNS operators and firewall coordination |
| `26-troubleshooting.png` | Partial | Current DNS/TCP/TLS/HTTP diagnostics are logged; controlled fault drill not run |
| `27-final-system-verification.png` | Partial | Current evidence is logged; main edge and backup DNS remain blockers |

For pending coordinated tests, do not capture until the test is approved and
actually performed. The grouped script above captures current failures
truthfully; it does not create screenshots for tests that were not run.
