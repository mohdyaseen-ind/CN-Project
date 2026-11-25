# Three-Mac Setup and Safety Checklist

## Before changing any service

- Confirm all assigned addresses and the `10.7.16.0/20` subnet with the team.
- Verify each member's active interface (`en0` expected).
- Back up any existing system-level configuration before changing it.
- Preserve managed firewall policy; never disable the firewall to make a test pass.
- Do not share or commit private keys or passwords.

## Address/service assignments

| Member | Assignment |
|---|---|
| Prateek | `10.7.28.39`: primary DNS, Backend A `:3001`, standby nginx `:8080/:8443` |
| Sankalp | `10.7.26.113`: main nginx, HTTPS/load balancing `:8080/:8443` |
| Sarthak | `10.7.18.197`: backup DNS, Backend B `:3002`, test client/Wireshark |

The project names are `app.team1.test` and `api.team1.test`; both currently
resolve to the main edge at `10.7.26.113`. DNS uses TCP and UDP port 53 and
records have a 30-second TTL.

## Prateek local launch

```sh
./scripts/backend-a-start.sh
./scripts/backend-a-status.sh
./scripts/standby-nginx.sh config-test
./scripts/standby-nginx.sh start
```

Use the paired `stop` scripts only for the project-managed local services.
Keep Backend A running until Sankalp confirms integration and any coordinated
failure demonstration.

## Coordination gates

- Do not stop primary dnsmasq until Sarthak confirms remote backup DNS queries.
- Do not mutate DNS records until both DNS operators agree on the before/after
  values and cache/TTL demonstration window.
- Do not stop Backend A until Sankalp confirms the high-availability test.
- Do not activate PF rules until Phase 1 connectivity is verified, the team
  approves, and the device administrator confirms the active anchor policy.
- Do not change both DNS records for edge migration until the team has validated
  standby TLS, backend connectivity, certificate trust, and rollback.

## Phase 2 evidence

Save actual command output in `evidence/phase2/prateek/logs/`. Save real
terminal screenshots in `evidence/phase2/prateek/`; use the evidence index to
see what remains pending. Never create blank or simulated screenshots.
