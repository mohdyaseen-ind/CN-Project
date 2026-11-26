# Private Network Service Platform — Integrated Report (Draft)

**Status:** integrated draft based on reports from all three roles and Sankalp's
current live baseline checks. It is not a claim that every required test has
passed. Coordinated failover, firewall isolation, DNS cache mutation, and edge
migration remain pending.

## 1. Architecture and request path

The current team assigns Prateek `10.7.28.39` (primary DNS, Backend A, standby
nginx), Sankalp `10.7.26.113` (backup DNS, main nginx/TLS/load balancing), and
Sarthak `10.7.18.197` (Backend B, client/Wireshark). The expected subnet is
`10.7.16.0/20`; actual reports show `/20` on Prateek and `/19` on Sankalp and
Sarthak. All reports list gateway `10.7.0.1`. The network prefix difference
needs team/network-administrator confirmation.

```text
Client
  -> primary/backup DNS :53 (UDP/TCP)
  -> main edge 10.7.26.113:8080 (HTTP redirect) / :8443 (TLS)
  -> nginx round-robin upstream
       -> Backend A 10.7.28.39:3001
       -> Backend B 10.7.18.197:3002
  <- JSON response with X-Backend and X-Edge
```

Both project names are configured to resolve to the primary edge. Sankalp's
system resolver has not been changed. The new backup DNS service is not yet
running or remotely verified, so client cutover remains pending.

## 2. Implementation and Phase 1 baseline

The project contains primary/backup dnsmasq templates, shared backend source,
standby and main nginx configs, TLS setup, backend isolation PF templates and
rollback scripts, lifecycle scripts, diagnostics, topology documentation, and
role reports. Sankalp's main edge uses round-robin upstreams with passive
`max_fails`/`fail_timeout`, retries eligible upstream failures, proxy timeouts
and forwarding headers, preserves backend identity, adds `X-Edge: primary`, and
redirects HTTP to HTTPS. Its PID and logs are project-local.

Sankalp verified nginx `1.31.10` syntax and started/reloaded only the
project-managed service. The default Homebrew service remains stopped. From the
main edge, Backend A and B status requests both returned HTTP 200 and their
respective `X-Backend` headers. Six HTTPS requests alternated A/B. The edge
returned 301 from `:8080` to `:8443`, successfully served `/`, `/api/status`,
and `/api/catalog`, and added `X-Edge: primary`.

The catalog returned `Cache-Control: max-age=60` and an ETag; a conditional
request returned `304 Not Modified`. HTTP/1.1 and HTTP/2 returned 200. Homebrew
OpenSSL verified TLS 1.2 and TLS 1.3 and both SAN hostnames using the local
self-signed certificate as explicit trust. System Keychain/browser trust has
not been installed. The captured current commands and timestamps are in
`evidence/phase2/sankalp/logs/06-baseline-integration.txt` and
`07-additional-verification.txt`.

Prateek's role report records primary DNS UDP/TCP responses with TTL 30,
external DNS forwarding, local Backend A 200/cache/304, and locally tested
standby TLS/redirect behavior. Sarthak's pre-reassignment report records local
backup DNS and Backend B checks plus Wireshark capture-permission checks; the
DNS role has since moved to Sankalp. Keep those results labeled with their
original host and time.

## 3. Current cross-host verification

From Sankalp's laptop, both peer pings succeeded. TCP connections to primary
DNS and both backend ports succeeded. Primary DNS answered both names over UDP
and TCP, with TTL 30, and forwarded an `example.com` lookup. Backend A and B
returned HTTP 200 with their identity headers.

Before the role change, Sankalp's queries to Sarthak's backup DNS timed out or
reset, motivating the transfer. On 2026-11-26, dnsmasq 2.93 was installed,
TCP/UDP port 53 had no listener, and the enabled macOS Application Firewall
permitted the dnsmasq executable. The new project config syntax passed. PF
state is not readable without admin access. The user authorized the resolver
start, but an authenticated sudo session is still required to bind port 53;
Terminal launch through computer control was denied by desktop policy. The
service remains stopped. See `evidence/phase2/sankalp/logs/17-backup-dns-config-test.txt`
and `18-backup-dns-prestart-audit.txt`. Do not stop Prateek's primary DNS until
both teammates confirm remote UDP/TCP answers from their clients.

## 4. Phase 2 extensions

### A. Backup DNS failover — CONFIG PREPARED; SERVICE/REMOTE CHECK PENDING

The backup DNS role moved from Sarthak to Sankalp. Config syntax passes, but the
service is not running because an authenticated sudo session is still needed
to bind port 53. Client DNS settings were not changed and Prateek's primary was not
stopped. Prateek and Sarthak must verify the service over UDP/TCP before any
primary-DNS outage test.

**Learning summary:** Redundant resolvers provide failover only if both are
reachable from clients and return consistent answers. Local resolver health
does not demonstrate remote service or client failover.

### B. DNS TTL and client cache — PARTIAL

Primary direct responses show TTL 30. No client cached result, record mutation,
expiry, or explicit flush was demonstrated. No records were changed.

**Learning summary:** TTL bounds permitted cache reuse; a direct query to an
authoritative resolver cannot establish how a client cache behaves.

### C. Backend service isolation — PREPARED, NOT ACTIVATED

PF rules and reversible scripts exist for Backend A/B; syntax-only `pfctl -nf`
checks passed. Read-only active PF inspection was denied at `/dev/pf`, and no PF
rule was activated or tested. Activation requires each backend host's admin
authorization and a confirmed anchor backup. Both backend services are
currently reachable from Sankalp's main edge.

**Learning summary:** Isolation should admit the approved edge and loopback,
deny unauthorized clients, and preserve DNS/other services. Both positive and
negative source tests are required.

### D. High availability — NOT RUN

Baseline A/B load balancing is verified. Neither backend was stopped because
the team has not confirmed a READY window. The primary edge host remains a
single point of failure.

**Learning summary:** Passive health handling and eligible retries can direct
later requests to a surviving backend, but do not prevent all in-flight errors
or protect a single edge host.

### E. Standby edge migration — BLOCKED

Prateek reports local standby tests, but Sankalp's remote HTTP request returned
an empty reply and the TLS handshake closed. No DNS records were changed. The
standby public certificate/trust and upstream path must be verified before
migration.

**Learning summary:** Migration requires trusted TLS and working upstreams as
well as coordinated updates to both DNS servers; cached clients may continue
reaching the original edge until their TTL expires.

### F. Troubleshooting — PREPARED, PRACTICE FAULT PENDING

`scripts/diagnose-edge.sh` tests DNS, TCP, TLS and HTTP. It correctly reports
primary DNS and the main edge healthy while showing backup DNS query failures.
No artificial config fault or faculty-injected test has been run.

**Learning summary:** Checking layers separately helps distinguish name
resolution, TCP setup, TLS identity, HTTP routing, and upstream errors without
assuming a single cause for every failure.

## 5. Evidence and packet analysis

Current Sankalp logs include host inventory, peer reachability, DNS, TLS,
nginx, redirect, load balancing, cache, 304, and diagnostic output. The evidence
index maps the 27 requested screenshots to actual status and does not create
placeholders. Historical Phase 1 screenshots are retained; reviewed captures
from older port/certificate settings are not reused as proof of the current
edge. One current primary DNS screenshot exists, but its heading labels the
test “FROM SARTHAK” while its visible terminal prompt is Sankalp's host; the
evidence index marks that provenance discrepancy and requests a corrected
capture before final use. No `.pcapng` file is currently present in the
repository. Sarthak's
Wireshark screenshots are historical visual evidence only; current packet
capture remains pending.

## 6. Troubleshooting findings

The first main-edge config check exposed incorrect relative certificate paths;
nginx resolved the certificate path under `configs/edge/`. The paths were
corrected to the project certificate location while PID/log paths remain
relative to the configured project prefix. The next syntax check passed.
Nginx also warned that 1024 worker connections exceeded the current 256 file
descriptor limit, so the project config was reduced to 128 and successfully
reloaded.

The system `curl` build uses SecureTransport and did not support the forced
TLS 1.3 option. Homebrew OpenSSL `s_client -tls1_3` independently verified the
server handshake and hostname. This was a client build limitation, not a server
TLS failure.

The diagnostic script initially returned success despite failed probes and
skipped its HTTP checks after a premature exit. It was corrected to run all
layers, aggregate failures, and exit nonzero when a probe fails. The latest
result is nonzero because backup DNS still times out; primary DNS, both
backends, and the primary HTTPS edge pass.

## 7. Individual contributions and limitations

- **Prateek:** primary DNS, Backend A, standby nginx and prepared Backend A
  firewall controls; report contains local DNS/backend/standby results.
- **Sankalp:** backup dnsmasq configuration, main nginx edge, TLS, upstream
  balancing, remote baseline integration, diagnostics, and report assembly.
- **Sarthak:** Backend B, client setup, and Wireshark readiness; prior report
  contains local DNS/backend and firewall observations.

The main edge remains a single point of failure. Backup DNS remote service,
standby remote HTTPS/trust, cache-aware DNS behavior, isolation rules, failure
tests, migration, current packet capture, client system trust, and the
`/19` versus `/20` prefix discrepancy remain open. No coordinated failure or
migration test has been claimed as passed.
