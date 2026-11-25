# Private Network Service Platform

Course project for Phase 1 and the applicable Phase 2 extensions.

## Three-laptop design

| Member | Address | Services |
|---|---:|---|
| Prateek (this Mac) | `10.7.28.39` | Primary DNS, Backend A (`:3001`), standby nginx (`:8080`/`:8443`) |
| Sankalp | `10.7.26.113` | Main nginx, HTTPS and load balancing |
| Sarthak | `10.7.18.197` | Backup DNS, Backend B (`:3002`), test client and Wireshark |

The expected subnet is `10.7.16.0/20`, interface `en0`, DNS port `53` TCP/UDP,
and DNS TTL `30` seconds. These addresses are the team-provided assignments;
only Prateek's current address and interface have been checked from this Mac.
See [docs/IP-INVENTORY.md](docs/IP-INVENTORY.md) for measured versus assigned
network facts and current verification limits.

Both `app.team1.test` and `api.team1.test` currently resolve to Sankalp's main
edge (`10.7.26.113`). Do not change either DNS server to the standby edge or
stop primary DNS during the coordinated demonstrations without team approval.

## Prateek: local launch and checks

Requires Python 3 and Homebrew nginx. This repository's scripts use project-local
state/log files under `var/`, which is git-ignored.

```sh
./scripts/backend-a-start.sh
./scripts/backend-a-status.sh
./scripts/standby-nginx.sh config-test
./scripts/standby-nginx.sh start
./scripts/standby-nginx.sh status
```

After editing the standby configuration, run `./scripts/standby-nginx.sh reload`
to validate it and gracefully reload only the project-managed nginx process.

Backend A serves `/`, `/api/status`, and `/api/catalog`. The catalog returns
`Cache-Control` and `ETag` and responds `304 Not Modified` when passed its
`If-None-Match` value. Keep Backend A running for Sankalp's integration work.
The standby proxy uses the existing local certificate if available and does
not replace Homebrew's global nginx configuration.

```sh
./scripts/standby-nginx.sh stop
./scripts/backend-a-stop.sh
```

Stop scripts affect only the project-managed process. Do not stop Backend A
for an availability demonstration until Sankalp has acknowledged the test.

## Configuration and docs

- [configs/dns/dnsmasq.conf](configs/dns/dnsmasq.conf) and
  [configs/dns/team.hosts](configs/dns/team.hosts): Prateek's primary DNS
  template and current project records.
- [configs/dns/dnsmasq-backup.conf](configs/dns/dnsmasq-backup.conf): Sarthak's
  backup DNS template.
- [configs/edge/nginx.conf](configs/edge/nginx.conf): Sankalp's main-edge
  template with both assigned backend addresses.
- [configs/edge/nginx-standby.conf](configs/edge/nginx-standby.conf): standalone
  standby proxy on ports 8080/8443.
- [docs/phase2/tls-setup.md](docs/phase2/tls-setup.md): local certificate setup,
  trust, and private-key handling.
- [configs/firewall/backend-pf.conf](configs/firewall/backend-pf.conf):
  prepared, not activated, Backend A isolation rules.
- [docs/phase2/prateek-report.md](docs/phase2/prateek-report.md): actual
  verification results, pending coordination, and extension learning summaries.
- [docs/phase2/troubleshooting.md](docs/phase2/troubleshooting.md): DNS/TCP/TLS/HTTP
  diagnostics.
- [evidence/phase2/prateek/README.md](evidence/phase2/prateek/README.md):
  evidence index and screenshot status.

## Safety and evidence

Never commit private keys, disable the managed firewall, edit system configs
without a backup, or claim a coordinated failure test succeeded without running
it with the team. The current local certificate and key are ignored by Git;
share only a public certificate/CA certificate after approval. Firewall
activation, DNS failover, TTL mutation, Backend A failure, and edge migration
are intentionally not run by an individual member.

Terminal logs in `evidence/phase2/prateek/logs/` contain only commands actually
run from this Mac. Screenshots are not synthesized; the evidence index gives
the exact capture instructions for screenshots that still need manual capture.
