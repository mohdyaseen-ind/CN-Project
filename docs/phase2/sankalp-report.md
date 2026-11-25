# Phase 2 Report — Sankalp

**Status:** in progress; checkpoint 1 prepared, runtime validation pending nginx availability.  
**Audit date:** 2026-11-25 (Asia/Kolkata).

## Role and current topology

Sankalp's assigned machine is `10.7.26.113`, main edge on `en0`, in
`10.7.16.0/20`. The local host reports `en0` active with IPv4
`10.7.26.113`, mask `255.255.224.0`, broadcast `10.7.31.255`. The provided
team assignments are Prateek `10.7.28.39` (primary DNS and Backend A) and
Sarthak `10.7.18.197` (backup DNS and Backend B). Their addresses and service
states have not been verified from this host. Gateway and DNS resolver details
were not returned by this session's route/resolver inspection.

## Changes from Phase 1

- Reworked the main nginx template to keep PID and logs project-local, provide
  round-robin upstream selection with passive failure limits, retry eligible
  failures, set proxy timeouts and forwarding headers, preserve backend response
  headers, add `X-Edge: primary`, and redirect HTTP to HTTPS.
- Added `scripts/edge-nginx.sh` with config-test, start, stop, reload, and status
  actions. It refuses to signal an unverified PID and checks the config before
  start/reload.
- Added `scripts/diagnose-edge.sh` for DNS, TCP, TLS, and HTTP checks.
- Existing repo code already provides backend cache control and ETag behavior,
  DNS templates, standby edge template, and Prateek's report. Those existing
  artifacts were retained.

## Test methodology and observed results

The audit checked the current interface/address, package availability, project
configuration, and reachability of both peers. Outputs are kept in
`evidence/phase2/sankalp/logs/`.

- `en0`: active; `10.7.26.113/20`, matching this host's assignment.
- Homebrew and OpenSSL 4.0.3 are installed. Python 3, curl, and tshark are
  available. Homebrew nginx is not installed. Wireshark's command-line `tshark`
  is available; GUI availability was not checked.
- Homebrew nginx installation was approved and attempted, but Homebrew reports
  its prefix and cache/log directories are not writable by this account. It
  suggests a broad `sudo chown` repair across `/opt/homebrew`; that system-wide
  ownership change was not performed. Nginx validation remains blocked pending
  an administrator-approved Homebrew repair or an administrator-managed nginx
  installation.
- The newly generated local certificate passed `openssl verify` with hostname
  checking for both `app.team1.test` and `api.team1.test`; validity is
  2026-11-25 through 2027-11-25. It is self-signed, so client trust remains
  pending. Its private key is ignored by Git and remains under the local
  `edge/certs/` directory.
- Ping and `nc` peer probes were denied by the managed execution environment
  (`Operation not permitted`). Curl to the assigned backend addresses failed to
  connect. These results do not establish that the laptops or services are
  down; they leave peer reachability unverified here.
- No project DNS resolver was returned by `scutil --dns` in this session.
- Historical screenshots under `evidence/01-lan/` are explicitly marked as
  belonging to the former four-Mac arrangement and are not evidence for this
  three-laptop topology. No active four-Mac service configuration was found in
  the audited source/config files.
- The nginx syntax check and live edge tests have not passed or been claimed:
  nginx is missing and peer services are not reachable from this environment.
  The diagnostic script also recorded socket restrictions for DNS, TCP, and
  curl in this execution environment.

## Phase 2 extensions

### A. Backup DNS failover

Not run. First verify both DNS servers remotely and coordinate with both DNS
operators. Do not stop primary DNS before Sarthak confirms backup answers.

**Learning summary:** DNS redundancy only helps when the client can query both
servers and both serve consistent records; failover must be tested at the
resolver as well as with direct server queries.

### B. DNS TTL and cache

Not run. The DNS templates specify 30 seconds, but the client resolver path and
records were not verified. Test cached and updated answers through the system
resolver, wait past TTL, and record an explicit cache flush.

**Learning summary:** TTL controls how long a recursive or client cache may
reuse an answer; a direct `dig @server` bypasses the cache and cannot prove
client cache expiry.

### C. Service isolation

Not run. Verify edge-to-backend connectivity and backend denial from an
unauthorized client under the existing firewall policy. Do not alter managed
firewall rules without authorization and a rollback snapshot.

**Learning summary:** A backend should accept traffic from the edge while
rejecting direct client access; reachability needs to be checked from both
allowed and disallowed source hosts.

### D. High availability

Not run. Requires both backends healthy, live edge validation, and coordinated
approval before stopping Backend A. No failure was induced.

**Learning summary:** Passive health checks remove a failing upstream after
eligible failures and retry requests where safe, but they do not eliminate
failures already in flight or make a single edge redundant.

### E. Edge migration

Not run. Requires Prateek's standby edge, a trusted standby certificate, and
coordinated record updates on both DNS servers with rollback prepared.

**Learning summary:** DNS changes are gradual because clients and recursive
resolvers retain cached records; migration has to account for both old and new
edge traffic during the TTL window.

### F. Troubleshooting

The diagnostic script is prepared but has not been run against a working path.
Record a controlled practice fault, actual diagnosis, repair, and retest only
after the integrated service is available. Faculty-injected evaluation remains
pending.

**Learning summary:** Layered diagnosis separates name resolution, TCP
reachability, TLS identity, HTTP routing, and upstream availability so that a
failure can be localized from observed evidence.

## Limitations and single points of failure

The primary nginx edge is a single point of failure until the standby edge is
validated and DNS migration is demonstrated. The two DNS services and two
backend hosts have not been independently verified from this machine. The
self-signed certificate requires client trust installation before normal
browser/curl validation.

## Current checkpoint and handoff

- **Checkpoint 1:** Main nginx and TLS configuration prepared. Certificate SAN
  and hostname checks passed locally. Nginx config validation is blocked because
  Homebrew's installation directories are not writable; checkpoint is not
  marked passed until nginx syntax validation runs.
- **Checkpoint 2:** Pending reachable, verified Backend A and B.
- **Checkpoint 3:** Diagnostic script and project-local service controls are
  prepared; extension-specific coordination/configuration is pending.
- **Checkpoint 4:** Pending team coordination and all prerequisite checks.
- **Checkpoint 5:** Pending all evidence and team reports.

Messages to teammates:

- **Prateek:** Please confirm your current `en0` IPv4/subnet, primary DNS
  response for both names, and Backend A `:3001` health. Please share the public
  standby certificate and confirm standby nginx/backend reachability; keep your
  services running until we coordinate tests.
- **Sarthak:** Please confirm your current `en0` IPv4/subnet, backup DNS
  response for both names, Backend B `:3002` health, and whether you can test
  HTTPS from your client. Please keep backup DNS available for a coordinated
  failover test.
