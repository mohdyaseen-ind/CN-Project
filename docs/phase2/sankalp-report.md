# Phase 2 Report — Sankalp

**Status:** main-edge baseline verified; backup DNS config syntax passes, but
the service has not been started. The user authorized the start, but this
session cannot complete OS sudo authentication; remote verification is pending.
**Updated:** 2026-11-26 (Asia/Kolkata).

## Host and topology observations

Identity commands returned user `sankalpmtellur` and host
`MacBook-Pro-7.local`. `en0` is Wi-Fi, active, and has `10.7.26.113` with mask
`255.255.224.0` (`/19`), broadcast `10.7.31.255`, and default gateway
`10.7.0.1`. This differs from the team's expected `/20` mask
(`255.255.240.0`). Prateek's report says `/20`; Sarthak's report says `/19`.
All addresses are inside the expected `10.7.16.0/20` address range, but confirm
the prefix length with the network administrator before changing shared network
configuration.

The macOS Application Firewall is enabled (`State = 1`), block-all and stealth
mode are off. The Homebrew dnsmasq executable is explicitly permitted for
incoming connections; no firewall settings were changed. PF state could not be
read without `/dev/pf` administrator access, so only the application-firewall
policy has been checked.

## Backup DNS role transfer to Sankalp

Sankalp now hosts the backup resolver at `10.7.26.113`. Homebrew dnsmasq 2.93 is
installed, its brew service is not running, and no process currently listens on
TCP or UDP port 53. `configs/dns/dnsmasq-backup.conf` now binds only
`127.0.0.1` and `10.7.26.113`, uses the project `team.hosts`, forwards normal
DNS to `8.8.8.8` and `1.1.1.1`, and sets local TTL to 30 seconds. Its syntax
check passed. The project script provides start/status/stop/reload operations
without touching Homebrew's global dnsmasq configuration. The start was
authorized, but `sudo -n -v` confirms that interactive administrator
authentication is still required. Desktop policy denied launching Terminal
through computer control, so no credential prompt was available.

The local/LAN resolver tests have not yet run because binding privileged port
53 requires an authenticated sudo session. Primary DNS at Prateek remains
running. The macOS Application Firewall is enabled and allows the dnsmasq
binary, but active PF policy and end-to-end remote UDP/TCP access still must be
demonstrated after startup. A later running process was observed with the
relative argument `--conf-file=configs/dns/dnsmasq-backup.conf`; its UDP/TCP
queries returned NXDOMAIN for both project names. The expected host records
are present. The backup template now uses absolute hosts/log/PID paths, and the
launch script now passes the absolute config path. The current process must be
restarted from the project script for those deterministic paths to take effect.
See `evidence/phase2/sankalp/logs/20-backup-dns-nxdomain-diagnosis.txt`.

## Main edge and baseline integration

Homebrew nginx `1.31.10` was already installed and its default Homebrew service
is stopped. I used only `scripts/edge-nginx.sh`. The first elevated config check
found certificate paths were resolved relative to the config file while PID
and log paths were relative to the project prefix. The paths were corrected.
The config check then passed. I reduced `worker_connections` from 1024 to 128
after nginx logged that the login's descriptor limit is 256. The config passed
again and the project-managed edge was reloaded and verified on ports 8080 and
8443 (master PID 16958 at check time).

Read-only peer checks from this host observed:

- Primary DNS `10.7.28.39`: UDP answer for `app.team1.test` and TCP answer for
  `api.team1.test` both returned `10.7.26.113`, TTL 30. Backend A
  `10.7.28.39:3001/api/status` returned HTTP 200 and `X-Backend: A`.
- Backend B `10.7.18.197:3002/api/status` returned HTTP 200 and `X-Backend: B`.
- At the earlier topology, queries to Sarthak's backup DNS at `10.7.18.197`
  timed out/reset, motivating the reassignment. This result is historical; the
  current Sankalp backup resolver has not yet been started or tested remotely.
- Prateek standby HTTPS `10.7.28.39:8443` reset the HTTPS request during this
  audit; standby TLS/certificate is not verified remotely from this host.

The local project edge successfully returned HTTP 200 for `/api/status` and
`/api/catalog`, alternated `X-Backend: A` and `X-Backend: B` over six requests,
and added `X-Edge: primary`. HTTP port 8080 returned 301 to HTTPS port 8443.
`/api/catalog` returned `Cache-Control: max-age=60` and an ETag; a matching
`If-None-Match` returned HTTP 304. HTTP/1.1 and HTTP/2 both returned 200.
Homebrew OpenSSL 4.1.0 verified TLS 1.2 and TLS 1.3 handshakes and hostname
matching for both domain SANs using the local certificate as the explicit trust
anchor. The certificate is self-signed; system Keychain/browser trust has not
been installed. Requests used `--resolve` to pin the host while preserving the
domain/SNI; the host's normal system resolver currently has public DNS only and
returns no address for either project name. DNS settings were not changed.

The system `curl` uses SecureTransport and rejected forced TLS 1.3 as a
build-time unsupported option; Homebrew OpenSSL's `s_client -tls1_3` succeeded.
This distinction is recorded in the logs rather than presented as a server
failure. An early diagnostic-script version failed to aggregate unsuccessful
probes and returned a misleading overall success. The script was corrected to
finish DNS/TCP/TLS/HTTP checks and exit nonzero if any probe fails. The latest
run exits 1 for backup DNS while primary DNS, both backends, and the main edge
pass; see `15-diagnostic-script-final.txt`.

Detailed command outputs and timestamps are in
`evidence/phase2/sankalp/logs/06-baseline-integration.txt` and
`07-additional-verification.txt`. The earlier failed Homebrew install attempt
is preserved in `04-homebrew-nginx-install.txt`; nginx is now installed and the
edge is running.

## Phase 2 extension status and learning summaries

### A. Backup DNS failover — CONFIG PREPARED; SERVICE/REMOTE CHECK PENDING

The DNS backup role moved from Sarthak to Sankalp. Config syntax passes, but the
service is not yet running because administrator authorization is needed to
bind port 53. No client DNS settings were changed, and Prateek's primary DNS was
not stopped. After startup, both Prateek and Sarthak must verify UDP/TCP remote
answers before any primary-DNS stop test.

**Learning summary:** Redundant DNS only provides failover when the client can
reach both resolvers and both return consistent records. A local resolver test
does not prove remote service or client-side failover.

### B. DNS TTL and cache — PENDING

The primary DNS's direct responses showed TTL 30. System resolver lookups had no
answer because the current system DNS configuration lists public resolvers, not
the project resolvers. No records were changed, no cache test was claimed, and
no resolver settings were modified.

**Learning summary:** TTL governs caching after an answer reaches a resolver;
direct `dig @server` checks authoritative behavior but cannot prove client
cache retention, expiry, or flush behavior.

### C. Backend service isolation — PENDING

No PF rules were activated on either backend. `pfctl -nf` syntax checks passed
for both prepared files, but read-only queries to `/dev/pf` were denied, so the
active PF state could not be verified from this account. The prepared
role-specific rules and rollback scripts remain subject to host/admin approval.
Both upstream services are currently reachable from this edge.

**Learning summary:** Isolation should permit the edge source and loopback while
blocking unauthorized clients, and verification must test both allowed and
denied sources while preserving DNS and unrelated services.

### D. High availability — PENDING

Baseline round-robin to both backends is verified. Neither backend was stopped;
failure testing requires a team-confirmed READY window. The primary edge remains
a single point of failure.

**Learning summary:** Passive failure checks and retries can route eligible
requests to a surviving upstream, but in-flight requests can still fail and a
single edge process/host remains a separate failure domain.

### E. Standby edge migration — PENDING

Prateek's standby TLS endpoint reset during the remote handshake. No DNS record
was changed. Obtain and verify the standby public certificate, test standby
access to both backends, and coordinate DNS updates and rollback before
migration.

**Learning summary:** DNS migration is gradual because cached clients may keep
using the previous edge during the TTL window; trust, upstream access, response
identity, and rollback must all be verified before cutover.

### F. Troubleshooting — PREPARED; PRACTICE FAULT PENDING

`scripts/diagnose-edge.sh` covers DNS, TCP, TLS, and HTTP. Its latest run
correctly exits 1 for backup DNS while successful probes for primary DNS, both
backends, and the primary edge are logged in
`15-diagnostic-script-final.txt`. No artificial configuration fault has been
introduced. Faculty-injected results remain pending.

**Learning summary:** Testing DNS, TCP, TLS, HTTP, and upstreams as separate
steps helps localize faults from evidence and avoids attributing every timeout
to the firewall.

## Final requirement status

| Requirement | Status | Verification/evidence | Remaining action |
|---|---|---|---|
| Host address and interface | PASS with discrepancy | `00-audit-and-connectivity.txt`; `07-additional-verification.txt` | Reconcile `/19` vs expected `/20` with team/network administrator. |
| Primary DNS UDP/TCP | PASS from this host | `07-additional-verification.txt` | Verify from a second client. |
| Backup DNS installation/config | PASS | `17-backup-dns-config-test.txt` | Run the authorized start command from an authenticated Terminal session. |
| Backup DNS local/LAN answers | FAIL before fix | `20-backup-dns-nxdomain-diagnosis.txt`: NXDOMAIN over UDP/TCP | Restart only project backup dnsmasq using the grouped command and retest. |
| Backup DNS remote answers | PENDING | Remote test not run yet | Prateek and Sarthak must run documented verification commands. |
| Backend A and B | PASS from this edge | `06-baseline-integration.txt` | Preserve during coordinated failure tests. |
| Main nginx config and service | PASS | `06-baseline-integration.txt` | Capture actual screenshot after checks are displayed. |
| HTTPS, hostname, TLS 1.2/1.3 | PASS via explicit local CA trust | `01-tls-setup.txt`, `07-additional-verification.txt` | Install/coordinate client trust; browser test remains pending. |
| Redirect and load balancing | PASS | `06-baseline-integration.txt` | Capture screenshot. |
| Cache headers and 304 | PASS | `06-baseline-integration.txt` | Capture screenshot. |
| System DNS for project names | PENDING | `07-additional-verification.txt` | Configure only after backup DNS is verified; preserve rollback. |
| Standby edge and migration | BLOCKED | `07-additional-verification.txt` | Prateek to confirm standby listener/certificate; coordinate DNS window. |
| Phase 1 failure scenarios | PENDING REVIEW | `evidence/07-failures/` | Review old captures; repeat only missing tests after READY. |
| Phase 2 A–F | PENDING / PREPARED | This report and team reports | Coordinate required DNS, firewall, backend, migration and practice tests. |

## Coordination messages

- **Prateek:** Primary DNS and Backend A are verified from Sankalp. Please
  confirm standby nginx is listening on 8080/8443, share its public certificate
  or CA certificate, and investigate why remote HTTPS to `10.7.28.39:8443`
  resets. Keep services running; no disruptive test has been started.
- **Sarthak:** Backup DNS has moved to Sankalp. After the service is started,
  please run the UDP/TCP test block in `docs/phase2/sarthak-client-setup.md`
  from your client and send the actual output. Backend B remains reachable;
  please confirm the `/19` mask from your host.
