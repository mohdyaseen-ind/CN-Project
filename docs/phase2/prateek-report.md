# Phase 2 Report — Prateek

Updated: 2026-11-26 01:07 IST. This report separates observed results from
team-assigned values and tests that still require another laptop, administrator
approval, or a coordinated test window.

> Historical role note: this report predates the 2026-11-26 DNS role transfer.
> Sankalp now hosts backup DNS; Sarthak's old backup-DNS checks are historical.

## Role and host audit

- Role: primary DNS, Backend A, and standby nginx on `10.7.28.39`.
- Observed interface: `en0`, active, `10.7.28.39/20`; default gateway
  `10.7.0.1`. This matches the team assignment and expected subnet.
- Homebrew prefix: `/opt/homebrew`; dnsmasq `2.93` and OpenSSL `4.0.3` are
  installed. Homebrew nginx is now `1.31.10`, but the still-running standby
  process reports `1.31.6` (see `21-nginx-binary-runtime-version.txt`).
- Repository started clean. Existing `evidence/` and local certificate
  material were preserved. No system config was changed.
- Existing project certificate is valid through 2027-10-05, contains SANs for
  both domains, verifies against the local public CA certificate, and matches
  its local private key. The private key remains ignored by Git.
- Sankalp and Sarthak's host reports record `/19` masks, which differ from the
  expected `/20`. At 23:54, Sankalp responded to ping (2/2); Sarthak did not
  (0/2).
- macOS Application Firewall on this Mac reports enabled (`State = 1`).
  No PF rules were activated or changed.

## Follow-up integration audit — 2026-11-25 23:32–23:40 IST (historical)

| Requirement | Result observed at that time |
|---|---|
| Primary DNS UDP/TCP | Both names answer `10.7.26.113` with TTL 30 |
| Former backup DNS at Sarthak (`10.7.18.197`) | UDP times out; TCP connection resets; this was before the role transfer |
| Backend A from Prateek | `/api/status` HTTP 200, `X-Backend: A` |
| Backend B from Prateek | Direct `/api/status` HTTP 200, `X-Backend: B` |
| Standby HTTPS | Six verified HTTP/2 200 responses alternate `A`, `B`; every response has `X-Edge: standby` |
| Standby HTTP listener | HTTP 301 to HTTPS 8443 and `X-Edge: standby` |
| Sankalp host/network | Ping succeeds; TCP 8080 and 8443 now accept connections |
| Main-edge HTTP redirect | HTTP 301 to HTTPS 8443 |
| Main-edge TLS | Self-signed certificate has both SANs; verification with Prateek's CA fails (curl error 60) |
| Main-edge HTTPS/backend response | Not verified; stopped at certificate verification rather than bypassing trust |
| Main-edge configuration | Project config passes nginx syntax/TLS file validation on Prateek's host; not started here |
| Standby package/runtime version | Homebrew binary is 1.31.10; active process still serves 1.31.6 |

At that time Backend B returned HTTP 200 remotely. A newer 23:53 rerun below
returned an empty reply, so the earlier success is historical and Backend B
is not currently verified. Sarthak's report describes a managed firewall
profile blocking inbound traffic; Sarthak or the administrator must recheck
the managed firewall and service state. Logs are
`15-current-integration-audit.txt` through
`20-main-edge-config-test-fixed.txt` under
`evidence/phase2/prateek/logs/`; version evidence is in
`21-nginx-binary-runtime-version.txt`; main-edge connection and certificate
results are in `22-main-edge-first-check.txt` and
`24-main-edge-cert-fingerprint.txt`.

## Current evidence rerun — 2026-11-25 23:53–23:54 IST

The non-disruptive checks were rerun and saved to
`evidence/phase2/prateek/logs/25-current-evidence-rerun.txt`.

| Test | Current observed result |
|---|---|
| Prateek interface | `en0` is `10.7.28.39/20`; default gateway `10.7.0.1` |
| Peer reachability | Sankalp ping 2/2; Sarthak ping 0/2 (100% loss) |
| Primary DNS | UDP and TCP answers for both domains remain `10.7.26.113`, TTL 30 |
| Primary DNS service | dnsmasq process and TCP/UDP listeners on loopback and `10.7.28.39`:53 confirmed by `ps`/`netstat`; `lsof` emitted no rows |
| Backend A | HTTP 200, `X-Backend: A`; catalog ETag/Cache-Control verified and conditional request returned HTTP 304 |
| Backend B | Direct status request returned `curl: (52) Empty reply from server`; current service not verified |
| Standby HTTPS | Current `/api/status` returned HTTP/2 200 with `X-Backend: A` and `X-Edge: standby` |
| Standby distribution | Six fresh HTTPS requests all returned `X-Backend: A`; no current A/B alternation. Earlier alternation is historical and Backend B is presently unverified |
| Nginx config | Standby and main-edge config syntax tests pass on Prateek; main edge was not started |
| Main edge | HTTP 301 redirect works; HTTPS trust probe fails with curl error 60 for a self-signed certificate |
| Former Sarthak DNS address (`10.7.18.197`) | UDP query timed out; TCP reported connection reset; not a test of Sankalp's new backup service |

These are observed results, not diagnoses of the underlying network cause.
No DNS/service configuration was changed and no coordinated test was run.

## DNS role-transfer update — 2026-11-26 00:07 IST

Sankalp's report records that backup DNS moved to `10.7.26.113`. The
project-managed config passes syntax validation, but the service has not been
started because interactive administrator authentication is required. An
already-running dnsmasq process was observed using a relative config path and
returning NXDOMAIN for both project names; the config/script paths were
corrected, and restarting only that process through the project script remains
pending approval/authentication. The 23:53 Prateek probes to
`10.7.18.197:53` above predate or target the former assignment; they do not
verify the new backup resolver.

Sankalp also reports the main edge running locally: HTTP redirect, HTTPS with
explicit self-signed certificate trust, upstream Backend A/B responses,
round-robin headers, catalog cache headers, and TLS 1.2/1.3 passed from his
host. Prateek's 23:53 client still rejects that self-signed certificate with
curl error 60. Sankalp and Sarthak report Backend B responding, while
Prateek's earlier direct probe returned an empty reply; the source-dependent
discrepancy remains unresolved. See `docs/phase2/sankalp-report.md` and the
Sankalp DNS diagnostic logs.

## Checkpoint 1 — Primary DNS and Backend A

| Requirement | Result |
|---|---|
| dnsmasq listening on `127.0.0.1:53` and `10.7.28.39:53`, TCP and UDP | Verified |
| `app.team1.test` / `api.team1.test` resolve to `10.7.26.113` | Verified with direct UDP/TCP queries to the primary |
| TTL is 30 seconds | Verified in direct DNS answers |
| DNS forwarding | `example.com` resolved through primary DNS |
| Remote client query to primary | Sarthak's report records successful UDP/TCP queries from his host |
| Former backup DNS at `10.7.18.197` | Historical UDP timeout and TCP reset; backup role has moved to Sankalp |
| New backup DNS at `10.7.26.113` | Config syntax passes; service startup/remote UDP-TCP verification pending admin authentication |
| Backend A (`0.0.0.0:3001`) | Running; `/` and `/api/status` return HTTP 200 with `X-Backend: A` |
| Backend A cache | `/api/catalog` returned `Cache-Control`, ETag, then HTTP 304 for the matching conditional request |

Primary DNS was not stopped, reconfigured, or reloaded. The macOS system
resolver still lists public DNS servers; tests here explicitly queried the
project DNS server with `dig @10.7.28.39` and `dig @127.0.0.1`. Sarthak's
report records successful primary DNS queries from his host. This Mac's direct
query to its own LAN address is not a substitute for that remote evidence.

## Checkpoint 2 — Standby nginx

The standby nginx configuration is separate from Sankalp's main-edge template
and binds only the requested high ports. Its syntax passed, local HTTPS returned
HTTP 200 with `X-Backend: A` and `X-Edge: standby`, HTTP redirects for both
domains returned 301 to HTTPS port 8443, and verified TLS 1.2 and 1.3 handshakes
succeeded. The earlier standby integration test alternated requests between
Backend A and Backend B. In the 23:53 rerun, all six requests returned Backend
A only and the direct Backend B probe returned an empty reply. Therefore current
round-robin behavior is not verified. Sankalp's main-edge ports
are now open and HTTP redirects correctly, but its self-signed certificate is
not trusted by Prateek's current CA bundle. HTTPS/backend headers and main-edge
load balancing remain unverified; no `curl -k` was used.

## Checkpoint 3 — Phase 2 configuration

- DNS templates for both assigned DNS hosts and current records: prepared.
- Standby TLS/reverse-proxy config: prepared and locally testable.
- Backend A PF rules only: prepared for loopback plus Sankalp's assigned edge
  address; unrelated services/ports are not blocked by these rules.
- PF syntax is checked without loading rules. Current PF runtime/anchor state
  could not be inspected without administrator privileges. Rules are not
  active, the firewall was not enabled/disabled, and `/etc/pf.conf` was not
  changed.
- PF backup/rollback scripts are prepared; they require explicit administrator
  approval and an active-anchor check before use.
- Added `scripts/edge-nginx.sh` for Sankalp to validate, start, inspect,
  diagnose upstreams, probe load balancing, reload, and stop only the
  project-specific main nginx. It was syntax-checked and its config test passed
  on Prateek's host using the project-local certificate; it was not started
  here because this host is running the standby edge on the same ports.

## Checkpoint 4 — Coordinated demonstrations

No coordinated failure or migration test was initiated:

| Demonstration | Current status |
|---|---|
| DNS failover | Pending authorized start and remote verification of Sankalp's backup DNS; client test from Sarthak follows |
| DNS TTL/cache mutation | Pending both DNS operators and Sarthak's client |
| Backend A isolation | Not activated; pending Phase 1 reachability, admin and team approval |
| Backend A high availability | Not run; keep Backend A running until Sankalp acknowledges |
| Edge migration | Not run; pending cross-laptop standby TLS/backend/certificate validation |
| Layer diagnostics | Commands documented in `docs/phase2/troubleshooting.md` |

## Checkpoint 5 — Evidence and submission

Actual command logs are in `evidence/phase2/prateek/logs/`. The latest rerun is
`25-current-evidence-rerun.txt`. At the 00:04 audit, **6 PNG screenshots**
were present directly in `evidence/phase2/prateek/`:
`13-backend-a-restored.png`
(shows startup only, not a preceding outage) and `14-standby-nginx.png`
(historical verified standby test), plus four user-supplied Terminal screenshots
copied unchanged as `25-current-terminal-rerun-01.png` through
`25-current-terminal-rerun-04.png`. They document current results and show
`screencapture -i` failing with `could not create image from rect`.

The evidence index has 16 legacy screenshot filenames and 27 shared-checklist
filenames: 43 exact names total, 2 matching requested names, and
**41 exact filenames missing**. The four supplemental PNGs are actual Terminal
screenshots but do not use the checklist filenames.
The existing standby PNG semantically covers local HTTPS, but
`07-https-success.png` is absent under that exact name. The Backend A screenshot
does not prove HA recovery. The user ran
`./scripts/capture-prateek-evidence.sh` from Terminal, but interactive captures
failed with `could not create image from rect`; no per-test files were saved by
that run. The supplied screenshots were preserved unchanged as supplemental
evidence. Failures are shown as failures; unrun coordinated tests remain
without PNGs.

## Phase 2 learning summaries

**Extension A — DNS failover.** Redundant DNS only provides useful failover
when the client is configured with both reachable resolvers and both servers
answer the same project zone consistently. The backup role moved to Sankalp;
the config is syntax-valid, but the service needs an authorized start and
remote UDP/TCP verification before any primary outage test. The failed
23:53 query targeted Sarthak's former backup address, so it is not a test of
the new resolver and no failover result is claimed.

**Extension B — DNS TTL and cache behavior.** A DNS answer's TTL controls how
long a recursive client may reuse a cached record, so changing an authoritative
hosts file does not guarantee that an already-cached client immediately sees
the new edge. A valid demonstration must compare the authoritative answer, the
client's remaining TTL, expiry, and an explicitly flushed client cache; it
must restore both DNS servers' original records afterward. The primary's
30-second TTL is verified, but a coordinated cache-mutation demonstration has
not yet been performed.

**Extension C — Backend isolation.** Filtering only TCP port 3001 can restrict
direct access to Backend A while preserving DNS and unrelated services; an
explicit loopback exception is necessary for Prateek's local standby proxy.
Rules must be evaluated in order so the approved main edge is passed before
other traffic is blocked. The rule set is prepared but not activated, and no
blocked-client result is claimed.

**Extension D — High availability.** Round-robin selection distributes normal
requests, while passive failure detection and retry on eligible requests let
the surviving backend continue serving traffic after one backend fails. The
proxy should preserve the backend identity header so both load distribution
and failover can be observed. The earlier standby test alternated between A
and B; the current rerun returned A only while Backend B returned an empty
reply. A coordinated outage test has not been run, so no high-availability
result is claimed.

**Extension E — Edge migration.** A standby edge is useful only after its TLS
certificate, trust chain, and both upstream paths are independently validated.
Changing DNS on both authoritative servers introduces cache timing; the team
must observe the new `X-Edge` response and then restore both original records
and firewall permissions. Migration has not been attempted.

**Extension F — Layer-by-layer troubleshooting.** Separating DNS answers,
TCP connection establishment, TLS negotiation/certificate verification, and
HTTP status/headers narrows a failure to the relevant layer without assuming
that a timeout proves a firewall fault. Recording the source, destination,
timestamp, exact command, and result makes cross-host diagnosis reproducible.
The local DNS/TCP/TLS/HTTP checks are documented and partly verified; the
remote-path diagnosis remains pending teammate access.

## Pending dependencies / next coordination

1. Sankalp starts only the project-managed backup dnsmasq from an authenticated
   Terminal session, resolves the existing NXDOMAIN process/config mismatch,
   then verifies local UDP/TCP answers. Prateek and Sarthak independently test
   the new backup resolver at `10.7.26.113:53`.
2. Sankalp confirms main-edge upstream health and independently confirms the
   certificate fingerprint with Prateek; share/approve only the public cert or
   trust instructions. Prateek then tests `/api/status` and both backend
   identities without `-k`.
3. Sarthak and Sankalp reconcile the Backend B result: both report it working,
   while Prateek's latest direct probe returned an empty reply.
4. The `/19` masks reported by Sankalp and Sarthak versus the expected `/20`
   require network-administrator confirmation.
5. Before any PF activation, an administrator verifies the managed policy and
   active anchor and approves the specific temporary rule.
6. The team schedules DNS failover, TTL, service-isolation, HA, and migration
   demonstrations. Until then, keep primary DNS and Backend A running.

## Current completion status

| Requirement | Status | Observed result / evidence | Remaining action |
|---|---|---|---|
| Prateek identity/IP/subnet | PARTIAL (current) | `25-current-evidence-rerun.txt`; `10.7.28.39/20`, Sankalp ping 2/2, Sarthak ping 0/2 | Confirm Sarthak reachability |
| Primary DNS / 30s TTL | PASS (local) | `25-current-evidence-rerun.txt`; UDP/TCP answers and TTL 30 | Capture screenshot; client cache test remains pending |
| Former backup DNS at Sarthak | HISTORICAL FAILURE | Same log: UDP timeout, TCP reset to `10.7.18.197` before role transfer | Do not treat as test of new backup host |
| New backup DNS at Sankalp | PENDING | Sankalp report: config syntax passes; service not started; earlier wrong-config process returned NXDOMAIN | Authorized project-script start, local/remote UDP-TCP verification |
| Backend A | PASS | `03-backend-a-status.txt`; HTTP 200, `X-Backend: A` | Keep running |
| Backend B reachability | SOURCE-DEPENDENT | Sankalp/Sarthak report HTTP 200; Prateek's `25-current-evidence-rerun.txt` returned empty reply | Reconcile source-dependent result |
| Standby HTTPS | PASS (current probe) | Same log; HTTP/2 200, `X-Backend: A`, `X-Edge: standby` | Capture screenshot in interactive Terminal |
| Standby load balancing | PARTIAL / SOURCE-DEPENDENT | Prateek's six requests returned A only; Sankalp reports main-edge A/B alternation | Verify Backend B and capture each edge independently |
| Standby nginx upgrade | PENDING | `21-nginx-binary-runtime-version.txt`; installed 1.31.10, active service still 1.31.6 | Coordinate restart after Sankalp confirms no dependency on current standby |
| Main-edge listeners/redirect | PASS | Sankalp report: project edge running; Prateek's probe sees HTTP 301 | Preserve service during coordinated tests |
| Main-edge TLS/client trust | PASS on Sankalp / BLOCKED on Prateek | Sankalp verifies with explicit local certificate trust; Prateek gets curl error 60 | Confirm fingerprint out of band and configure approved client trust |
| Main-edge config | PASS | Syntax tests passed on Prateek and Sankalp; Sankalp reports project service running | Keep main-edge config and PID/log paths aligned |
| Firewall isolation / PF active state | PENDING | Existing dry-run only; no rules activated | Admin/team authorization and coordinated test |
| DNS failover, TTL mutation, HA outage, migration | PENDING | No disruptive tests performed | Team test window and required approvals |
| Wireshark packet captures | PENDING | Sarthak's guide/index only | Capture after main-edge TLS trust and remote DNS are resolved |
