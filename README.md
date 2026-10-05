# Computer Networks Project — Phase 1

Team: Prateek, Sankalp, Yaseen, Sarthak Mathapati

## Machine roles

| Mac | Member | Role | Main service |
|---|---|---|---|
| Mac 1 | Sankalp | Private DNS + Wireshark | dnsmasq / UDP 53 |
| Mac 2 | Prateek | Edge / Reverse Proxy / Load Balancer | nginx / HTTPS 443 |
| Mac 3 | Yaseen | Backend A | Python / TCP 3001 |
| Mac 4 | Sarthak Mathapati | Backend B + Test Client | Python / TCP 3002 |

## Request flow

Client -> DNS (Mac 1) -> app.team1.test resolves to Mac 2 -> HTTPS/nginx (Mac 2)
-> Backend A (Mac 3) OR Backend B (Mac 4)

## Folder map

- `backend/` — shared backend source
- `configs/dns/` — dnsmasq configuration and host records
- `configs/edge/` — nginx configuration
- `configs/tls/` — certificate-generation script
- `configs/firewall/` — Phase 2 backend firewall rule
- `docs/` — team documentation
- `evidence/01-lan` — IP table, pings, topology
- `evidence/02-dns` — DNS evidence
- `evidence/03-lb` — load-balancing evidence
- `evidence/04-tls` — HTTPS/TLS evidence
- `evidence/05-caching` — Cache-Control/ETag/304 evidence
- `evidence/06-wireshark` — .pcapng and packet screenshots
- `evidence/07-failures` — failure demonstrations

## Important

Replace placeholders such as `MAC1_IP`, `MAC2_IP`, `MAC3_IP`, and `MAC4_IP`
with the team's real LAN IPs before running the configuration.

Use a `.test` domain, not `.local`.

Do NOT share or commit private TLS keys (`*.key`) to GitHub or the team chat.

Phase 1 should be completed in this order:
1. LAN connectivity and fixed/reserved IPs
2. Private DNS
3. Backend A and B
4. TLS certificate
5. nginx reverse proxy + load balancing
6. HTTP caching
7. Wireshark capture
8. Failure demonstrations
9. Evidence + dry run
