# Phase 2 Report — Sarthak

Updated: 2026-11-25. This report separates directly observed results from
team-assigned values, managed-device blockers, and coordinated tests that remain
pending.

## 1. Role and Host Audit

- **Role:** Backup DNS (`dnsmasq`), Backend B (`:3002`), test client, and Wireshark packet analysis on `10.7.18.197`.
- **Observed Interface:** `en0` (active), IPv4 `10.7.18.197`, netmask `0xffffe000` (`/19`, `255.255.224.0`), broadcast `10.7.31.255`, default gateway `10.7.0.1`.
  - *Note:* Project docs list expected subnet `10.7.16.0/20`, while `en0` on this host is configured as `/19`.
- **Installed Tools:** Homebrew (`/opt/homebrew`), `dnsmasq` `2.93`, `python3` `3.14.2`, `dig`, and `/Applications/Wireshark.app` (`dumpcap` / `tshark` verified able to enumerate `en0`).
- **Peer Reachability (from `10.7.18.197`):**
  - Prateek (`10.7.28.39`): `ping` succeeds; Primary DNS (`10.7.28.39:53` UDP and TCP) resolves `app.team1.test` → `10.7.26.113`; Backend A (`10.7.28.39:3001/api/status`) returns `HTTP/1.1 200 OK` with `X-Backend: A`; Standby nginx (`10.7.28.39:8443`) TCP port is open.
  - Sankalp (`10.7.26.113`): `ping` succeeds; TCP `8080` and `8443` currently refuse connections (main nginx not yet started).

## 2. Checkpoint 1 — Firewall Diagnosis & Backend B

### Firewall Status & Remaining `dnsmasq` Blocker

- **Firewall State (Updated):** `/usr/libexec/ApplicationFirewall/socketfilterfw` now reports `State = 1` (*"Firewall is enabled"*), `Firewall has block all state set to disabled`, and `Firewall stealth mode is off`.
- **Application Rules:**
  - `/Library/Frameworks/Python.framework/Versions/3.14/Resources/Python.app` → `Allow incoming connections` (now effective — **Backend B on `10.7.18.197:3002` is reachable over the LAN**).
  - `/opt/homebrew/Cellar/dnsmasq/2.93/sbin/dnsmasq` → **`Block incoming connections`** (still blocked).
- **Impact:**
  - **Backend B (`10.7.18.197:3002`):** Verified working on both `127.0.0.1:3002` and LAN `10.7.18.197:3002` (`HTTP/1.1 200 OK`, `X-Backend: B`, `Cache-Control: max-age=60`, `ETag: "218f45a7f65b69a5"`, conditional `304 Not Modified`), with an active `ESTABLISHED` connection observed from Prateek (`10.7.28.39`).
  - **Backup DNS (`10.7.18.197:53`):** Works on `127.0.0.1:53` (UDP/TCP, TTL `30`, forwarding `example.com`), but queries to `10.7.18.197:53` still time out (UDP) / EOF (TCP) until `dnsmasq` is changed to `Allow incoming connections` in System Settings → Network → Firewall → Options.
- **Wireshark Capture Permissions:** `/Applications/Wireshark.app` is installed, but `/dev/bpf0` is `root:wheel crw-------` (`Permission denied` for `dumpcap -i en0`). Installing Wireshark's `ChmodBPF` helper is required before packet capture.

### Backend B Verification (`127.0.0.1:3002` & `10.7.18.197:3002`)

| Check | Result |
|---|---|
| Listener (`0.0.0.0:3002`) | Running via `scripts/backend-b-start.sh` |
| `GET /` | `HTTP/1.1 200 OK`, `X-Backend: B` |
| `GET /api/status` (`127.0.0.1` & `10.7.18.197`) | `HTTP/1.1 200 OK`, `X-Backend: B`, `{"backend": "B", "status": "ok", ...}` |
| `GET /api/catalog` | `HTTP/1.1 200 OK`, `Cache-Control: max-age=60`, `ETag: "218f45a7f65b69a5"` |
| `GET /api/catalog` (`If-None-Match`) | `HTTP/1.1 304 Not Modified` |
| LAN `10.7.18.197:3002` | **PASS** (verified locally & observed `ESTABLISHED` from `10.7.28.39`) |

## 3. Checkpoints 2–4 — Pending Dependencies

- **Checkpoint 2 (Backup DNS Remote Verification):** Blocked until administrator/faculty authorization adjusts the managed firewall profile (turning off "Block all incoming connections" while keeping Firewall ON, and allowing `dnsmasq`), or approves a faculty-authorized architecture adjustment.
- **Checkpoint 3 (Client Config & Wireshark):** Pending (a) remote DNS verification of both DNS servers before updating `en0` DNS settings, and (b) Sankalp starting main nginx (`10.7.26.113:8443`) and sharing the public TLS certificate (`ca.crt` / `app.crt`). `dumpcap` on `en0` is verified ready.
- **Checkpoint 4 (Coordinated Phase 2 Extensions A–F):** Prepared ([backend-b-pf.conf](../../configs/firewall/backend-b-pf.conf), backup/rollback scripts, client & Wireshark guides) and not yet executed pending team/admin coordination.

## 4. Phase 2 Learning Summaries

- **Extension A — Backup DNS Failover:** Redundant DNS only provides failover when the client configures both resolvers and both are reachable over the LAN on port 53 (UDP/TCP) with identical zone records (`team.hosts`). A managed firewall blocking port 53 on `en0` makes backup DNS appear healthy locally (`127.0.0.1`) while failing remotely.
- **Extension B — DNS TTL & Cache Behavior:** A 30-second `local-ttl=30` instructs stub/recursive resolvers how long to cache an A record before re-querying. Updating `team.hosts` does not immediately affect clients until the cached TTL expires or the local macOS cache is flushed (`dscacheutil -flushcache` + `killall -HUP mDNSResponder`).
- **Extension C — Service Isolation (PF):** Anchor-scoped `pf` rules (`com.apple/cnproject/backend-b`) can restrict TCP `3002` to Sankalp's edge (`10.7.26.113`) and `lo0` without modifying `/etc/pf.conf` or disrupting DNS/other services, while remaining reversible via backup/rollback scripts.
- **Extension D — High Availability:** Keeping Backend B (`3002`) running while Backend A (`3001`) stops lets the nginx upstream pool shift traffic to `X-Backend: B` without client errors, then resume round-robin load balancing when Backend A recovers.
- **Extension E — Edge Migration:** Migrating traffic to Prateek's standby edge (`10.7.28.39:8443`) requires coordinated DNS updates on both resolvers, valid TLS certificate trust on the client, and verification of `X-Edge: standby` before restoring original DNS records.
- **Extension F — Layer-by-Layer Troubleshooting:** Testing DNS (`dig`), TCP (`nc`), TLS (`openssl s_client`), and HTTP (`curl -i`) separately isolates where a failure occurs—for example, distinguishing a `dnsmasq` bind issue from a host firewall `State = 2` drop after TCP accept.
