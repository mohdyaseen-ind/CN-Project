# Sarthak Phase 2 Evidence Index

Command outputs are saved under [logs/](logs/) only after the command actually runs.
No screenshots or packet captures are fabricated; pending/blocked items remain absent until executed.

## Manual Screenshot Capture Commands

Display the relevant terminal output or Wireshark window, then run:

```sh
screencapture -i evidence/phase2/sarthak/03-backup-dns-service.png
screencapture -i evidence/phase2/sarthak/04-backup-dns-local-test.png
screencapture -i evidence/phase2/sarthak/05-backup-dns-remote-test.png
screencapture -i evidence/phase2/sarthak/06-backend-b-status.png
screencapture -i evidence/phase2/sarthak/07-client-dns-settings.png
screencapture -i evidence/phase2/sarthak/08-client-https-success.png
screencapture -i evidence/phase2/sarthak/09-wireshark-dns-query.png
screencapture -i evidence/phase2/sarthak/10-wireshark-dns-response.png
screencapture -i evidence/phase2/sarthak/11-wireshark-tcp-handshake.png
screencapture -i evidence/phase2/sarthak/12-wireshark-tls-clienthello.png
screencapture -i evidence/phase2/sarthak/13-wireshark-tls-serverhello.png
screencapture -i evidence/phase2/sarthak/14-wireshark-encrypted-data.png
screencapture -i evidence/phase2/sarthak/15-dns-failover.png
screencapture -i evidence/phase2/sarthak/16-dns-ttl-before.png
screencapture -i evidence/phase2/sarthak/17-dns-ttl-after.png
screencapture -i evidence/phase2/sarthak/18-dns-cache-flush.png
screencapture -i evidence/phase2/sarthak/19-firewall-isolation.png
screencapture -i evidence/phase2/sarthak/20-high-availability.png
screencapture -i evidence/phase2/sarthak/21-edge-migration.png
screencapture -i evidence/phase2/sarthak/22-troubleshooting.png
```

## Screenshot Checklist

| File | Evidence / Test | Status |
|---|---|---|
| `01-firewall-status.png` | macOS Firewall status ("Block all incoming connections" locked by profile) | Captured |
| `02-dnsmasq-permission.png` | Firewall Options showing `dnsmasq` blocked & profile lock | Captured |
| `03-backup-dns-service.png` | `dnsmasq` process, TCP/UDP port 53 listeners, config | Log available (`01-firewall-diagnosis.txt`); screenshot pending |
| `04-backup-dns-local-test.png` | Localhost UDP/TCP `dig @127.0.0.1` + forwarding | Log available (`03-backup-dns-local.txt`); screenshot pending |
| `05-backup-dns-remote-test.png` | Remote DNS queries to `10.7.18.197:53` from peers | **Blocked** by `dnsmasq` per-app `Block incoming connections` rule |
| `06-backend-b-status.png` | Backend B `/`, `/api/status`, `/api/catalog` 200 & 304 | **PASS** on `127.0.0.1` & `10.7.18.197:3002` (`02-backend-b-verification.txt`); screenshot pending |
| `07-client-dns-settings.png` | `en0` configured with `10.7.28.39` & `10.7.18.197` | Pending remote backup DNS verification |
| `08-client-https-success.png` | `https://app.team1.test:8443` without `-k` | Pending Sankalp main edge & public cert |
| `09-wireshark-dns-query.png` | Wireshark DNS query packet | Pending Checkpoint 3 |
| `10-wireshark-dns-response.png` | Wireshark DNS response packet (TTL 30, edge IP) | Pending Checkpoint 3 |
| `11-wireshark-tcp-handshake.png` | Wireshark TCP 3-way handshake to port 8443 | Pending Sankalp main edge |
| `12-wireshark-tls-clienthello.png` | Wireshark TLS ClientHello | Pending Sankalp main edge |
| `13-wireshark-tls-serverhello.png` | Wireshark TLS ServerHello | Pending Sankalp main edge |
| `14-wireshark-encrypted-data.png` | Wireshark Encrypted Application Data | Pending Sankalp main edge |
| `15-dns-failover.png` | Coordinated primary DNS stop & backup resolution | Pending Checkpoint 4 (requires backup DNS remote fix) |
| `16-dns-ttl-before.png` | TTL before-change cached vs fresh query | Pending Checkpoint 4 |
| `17-dns-ttl-after.png` | TTL expiry after 30s | Pending Checkpoint 4 |
| `18-dns-cache-flush.png` | Manual macOS resolver cache flush | Pending Checkpoint 4 |
| `19-firewall-isolation.png` | Backend B PF isolation & rollback | Rules prepared; not activated; pending admin/team approval |
| `20-high-availability.png` | Backend A down, Backend B serving HTTPS, recovery | Pending Checkpoint 4 |
| `21-edge-migration.png` | Coordinated cutover to standby edge (`X-Edge: standby`) | Pending Checkpoint 4 |
| `22-troubleshooting.png` | Layer-by-layer DNS/TCP/TLS/HTTP diagnostics | Pending Checkpoint 4 |

## Packet Captures (`.pcapng`)

| File | Scope | Status |
|---|---|---|
| `dns.pcapng` | Project DNS traffic (`port 53`) | Pending Checkpoint 3 |
| `tcp-handshake.pcapng` | TCP 3-way handshake (`port 8443`) | Pending Sankalp main edge |
| `tls-handshake.pcapng` | TLS ClientHello / ServerHello | Pending Sankalp main edge |
| `complete-request-flow.pcapng` | Full DNS + TCP + TLS + HTTP flow | Pending Sankalp main edge |
| `dns-failover.pcapng` | Backup DNS failover capture | Pending Checkpoint 4 |
| `edge-migration.pcapng` | Standby edge migration capture | Pending Checkpoint 4 |
