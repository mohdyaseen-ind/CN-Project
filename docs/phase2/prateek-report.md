# Phase 2 Report — Prateek

Updated: 2026-11-25. This report separates observed results from team-assigned
values and tests that still require another laptop, administrator approval, or
a coordinated test window.

## Role and host audit

- Role: primary DNS, Backend A, and standby nginx on `10.7.28.39`.
- Observed interface: `en0`, active, `10.7.28.39/20`; default gateway
  `10.7.0.1`. This matches the team assignment and expected subnet.
- Homebrew prefix: `/opt/homebrew`; dnsmasq `2.93`, nginx `1.31.6`, and
  OpenSSL `4.0.3` are installed.
- Repository started clean. Existing `evidence/` and local certificate
  material were preserved. No system config was changed.
- Existing project certificate is valid through 2027-10-05, contains SANs for
  both domains, verifies against the local public CA certificate, and matches
  its local private key. The private key remains ignored by Git.
- Peer addresses and their interface state are team-provided, not observed on
  those laptops. From this Mac, the backup DNS query and connection attempts to
  the main-edge and Backend B ports timed out.

## Checkpoint 1 — Primary DNS and Backend A

| Requirement | Result |
|---|---|
| dnsmasq listening on `127.0.0.1:53` and `10.7.28.39:53`, TCP and UDP | Verified |
| `app.team1.test` / `api.team1.test` resolve to `10.7.26.113` | Verified with direct UDP/TCP queries to the primary |
| TTL is 30 seconds | Verified in direct DNS answers |
| DNS forwarding | `example.com` resolved through primary DNS |
| Remote client query to primary | Not verified; must be tested from Sarthak's laptop |
| Backup DNS at `10.7.18.197` | Query timed out from this Mac; requires Sarthak confirmation |
| Backend A (`0.0.0.0:3001`) | Running; `/` and `/api/status` return HTTP 200 with `X-Backend: A` |
| Backend A cache | `/api/catalog` returned `Cache-Control`, ETag, then HTTP 304 for the matching conditional request |

Primary DNS was not stopped, reconfigured, or reloaded. The macOS system
resolver still lists public DNS servers; tests here explicitly queried the
project DNS server with `dig @10.7.28.39` and `dig @127.0.0.1`. The remote
client requirement is still pending; local access to the LAN-bound address
does not substitute for a query from another laptop.

## Checkpoint 2 — Standby nginx

The standby nginx configuration is separate from Sankalp's main-edge template
and binds only the requested high ports. Its syntax passed, local HTTPS returned
HTTP 200 with `X-Backend: A` and `X-Edge: standby`, HTTP redirects for both
domains returned 301 to HTTPS port 8443, and verified TLS 1.2 and 1.3 handshakes
succeeded. This is not proof of main-edge integration: the main edge and
Backend B were unreachable from this host at audit time, and Sankalp must verify
the cross-laptop path.

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

## Checkpoint 4 — Coordinated demonstrations

No coordinated failure or migration test was initiated:

| Demonstration | Current status |
|---|---|
| DNS failover | Pending remote backup-DNS confirmation from Sarthak |
| DNS TTL/cache mutation | Pending both DNS operators and Sarthak's client |
| Backend A isolation | Not activated; pending Phase 1 reachability, admin and team approval |
| Backend A high availability | Not run; keep Backend A running until Sankalp acknowledges |
| Edge migration | Not run; pending cross-laptop standby TLS/backend/certificate validation |
| Layer diagnostics | Commands documented in `docs/phase2/troubleshooting.md` |

## Checkpoint 5 — Evidence and submission

Actual command logs are in `evidence/phase2/prateek/logs/`. The evidence index
lists all 16 requested screenshot names and distinguishes captured tests from
pending coordinated demonstrations. No screenshot has been fabricated. The
standby listener and Backend A are left running for integration.

## Phase 2 learning summaries

**Extension A — DNS failover.** Redundant DNS only provides useful failover
when the client is configured with both reachable resolvers and both servers
answer the same project zone consistently. A primary outage test must first
prove that Sarthak can query backup DNS remotely, then stop only the primary
for the agreed window and restore it afterward. The backup query timed out
from this Mac, so no failover result is claimed.

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
and failover can be observed. Backend B is currently unreachable from this Mac,
so no failover result is claimed.

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

1. Sarthak confirms his current address and remote DNS answers on UDP and TCP
   port 53.
2. Sankalp confirms his main nginx can reach Backend A at `10.7.28.39:3001`;
   Sarthak confirms Backend B is serving on `10.7.18.197:3002`.
3. Before any PF activation, an administrator verifies the managed policy and
   the active `com.apple/*` anchor and approves the specific temporary rule.
4. The team schedules DNS failover, TTL, service-isolation, HA, and migration
   demos. Until then, primary DNS and Backend A remain running.
