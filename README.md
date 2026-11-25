# Private Network Service Platform

Course project for Phase 1 and the applicable Phase 2 extensions.

## Three-laptop design

| Member | Address | Services |
|---|---:|---|
| Prateek | `10.7.28.39` | Primary DNS, Backend A (`:3001`), standby nginx (`:8080`/`:8443`) |
| Sankalp | `10.7.26.113` | Backup DNS, main nginx, HTTPS and load balancing |
| Sarthak | `10.7.18.197` | Backend B (`:3002`), test client and Wireshark |

The expected subnet is `10.7.16.0/20`, interface `en0`, DNS port `53` TCP/UDP,
and DNS TTL `30` seconds. Current role reports show the assigned addresses are
in range but the observed masks differ (`/20` on Prateek, `/19` on Sankalp and
Sarthak); confirm the intended prefix before changing shared settings. See
[docs/IP-INVENTORY.md](docs/IP-INVENTORY.md) for measured versus assigned
network facts and current verification limits.

The primary currently resolves both `app.team1.test` and `api.team1.test` to
Sankalp's main edge (`10.7.26.113`). Backup DNS has moved from Sarthak to
Sankalp. Its project configuration passes syntax validation, but the service
has not yet been started and verified remotely; an existing incorrectly
launched process returned NXDOMAIN. Do not stop primary DNS or configure client
failover until Sankalp's backup answers are verified over UDP and TCP.

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

## Sankalp: main-edge launch

On Sankalp's Mac only, install nginx through the authorized Homebrew setup if
needed, verify both configured upstreams, then use the project-specific
lifecycle script. Do not start the default Homebrew nginx service.

```sh
./scripts/edge-nginx.sh upstreams
./scripts/edge-nginx.sh config-test
./scripts/edge-nginx.sh start
./scripts/edge-nginx.sh status
./scripts/edge-nginx.sh probe
```

`probe` makes six ordinary HTTPS status requests and prints their
`X-Backend` values. Generate or provision the main-edge certificate/key locally using
`bash configs/tls/gen-cert.sh`; never copy a private key between hosts. Set
`EDGE_CA_FILE=/path/to/approved/ca.crt` if the public trust certificate is not
available at the script's documented default paths.
Use `reload` and `stop` only for this project-managed main-edge process.

Backend A serves `/`, `/api/status`, and `/api/catalog`. The catalog returns
`Cache-Control` and `ETag` and responds `304 Not Modified` when passed its
`If-None-Match` value. Keep Backend A running for Sankalp's integration work.
The standby proxy uses the existing local certificate if available and does
not replace Homebrew's global nginx configuration. Homebrew nginx was upgraded
to 1.31.10, while the active standby process still reports 1.31.6; coordinate
before restarting it so Sankalp's integration is not interrupted.

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
- [configs/dns/dnsmasq-backup.conf](configs/dns/dnsmasq-backup.conf): Sankalp's
  backup DNS template.
- [scripts/backup-dns.sh](scripts/backup-dns.sh): project-local backup DNS
  config-test/start/status/stop/reload script; start/stop require admin rights.
- [configs/edge/nginx.conf](configs/edge/nginx.conf): Sankalp's main-edge
  template with both assigned backend addresses.
- [scripts/edge-nginx.sh](scripts/edge-nginx.sh): project-specific main-edge
  validation, lifecycle, upstream, and load-balancing checks for Sankalp.
- [configs/edge/nginx-standby.conf](configs/edge/nginx-standby.conf): standalone
  standby proxy on ports 8080/8443.
- [docs/phase2/tls-setup.md](docs/phase2/tls-setup.md): local certificate setup,
  trust, and private-key handling.
- [configs/firewall/backend-pf.conf](configs/firewall/backend-pf.conf):
  prepared, not activated, Backend A isolation rules.
- [docs/phase2/prateek-report.md](docs/phase2/prateek-report.md): actual
  verification results, pending coordination, and extension learning summaries.
- [docs/phase2/sankalp-report.md](docs/phase2/sankalp-report.md): main-edge
  integration results and remaining coordination items.
- [docs/phase2/sarthak-report.md](docs/phase2/sarthak-report.md): Sarthak's
  pre-reassignment DNS, Backend B, and Wireshark host report.
- [docs/submission/README.md](docs/submission/README.md): final package map and
  pending evidence status.
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

Role-specific terminal logs are stored in
`evidence/phase2/{prateek,sankalp,sarthak}/logs/` and distinguish each host's
observations. Screenshots are not synthesized; each role's evidence index lists
the current status and exact capture commands for remaining screenshots.
