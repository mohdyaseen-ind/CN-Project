# Three-Mac Architecture

```text
                         Private LAN: 10.7.16.0/20
          +----------------------+----------------------+
          |                      |                      |
  Prateek: 10.7.28.39    Sankalp: 10.7.26.113   Sarthak: 10.7.18.197
  Primary DNS :53        Main nginx :8080/:8443  Backup DNS :53
  Backend A :3001        TLS + round-robin        Backend B :3002
  Standby nginx          edge                     test client/Wireshark
          |                      |                      |
          +-- standby upstream --+-- main upstream -----+

  app.team1.test / api.team1.test -> 10.7.26.113 (current intended edge)
```

Both names currently point at Sankalp's main nginx. It load-balances between
Backend A at `10.7.28.39:3001` and Backend B at
`10.7.18.197:3002`. Prateek's standby nginx uses the same upstreams but
listens on HTTP `8080` and HTTPS `8443`; the HTTP listener redirects to HTTPS.

Prateek's `en0` address, `/20` mask, gateway, and primary DNS service were
checked locally. The other addresses are the team's assigned values and have
not been independently confirmed from those laptops in this session. Current
peer service connection attempts timed out; see the Phase 2 report.

## Service matrix

| Service | Host | Address/port | State |
|---|---|---|---|
| Primary DNS | Prateek | `10.7.28.39:53` UDP/TCP | Running; local DNS queries verified |
| Main edge | Sankalp | `10.7.26.113:8080/8443` | Peer not reachable from this Mac during audit |
| Backend A | Prateek | `10.7.28.39:3001` | Managed by project scripts |
| Backend B | Sarthak | `10.7.18.197:3002` | Peer not reachable from this Mac during audit |
| Backup DNS | Sarthak | `10.7.18.197:53` UDP/TCP | Query timed out during audit |
| Standby edge | Prateek | `10.7.28.39:8080/8443` | Project-local nginx config |

No DNS cutover or coordinated failover should be inferred from this diagram.
