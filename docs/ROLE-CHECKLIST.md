# Three-Mac Role Checklist

## Prateek — `10.7.28.39`

- Primary dnsmasq on UDP/TCP 53; verify local and remote queries.
- Backend A on TCP 3001; keep running for Sankalp's integration.
- Standby nginx on TCP 8080/8443 with the project TLS certificate.
- Prepare, syntax-check, back up, and document reversible Backend A PF rules.
- Collect Prateek's Phase 2 logs and screenshots without fabricating evidence.

## Sankalp — `10.7.26.113`

- Backup dnsmasq on UDP/TCP 53 after administrator-approved start; verify local
  and remote answers before primary DNS is stopped.
- Main nginx edge, TLS, and round-robin load balancing on 8080/8443.
- Verify access to both backend members and confirm X-Backend headers.
- Coordinate Backend A outage and standby edge migration with Prateek and Sarthak.

## Sarthak — `10.7.18.197`

- Backend B on TCP 3002.
- Act as the test client; capture Wireshark evidence.
- Verify Sankalp's backup DNS over UDP and TCP from Sarthak's client.
- Coordinate DNS TTL/cache tests and service-isolation tests with the team.
