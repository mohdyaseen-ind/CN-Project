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

The primary DNS currently points both names at the intended Sankalp edge,
`10.7.26.113`. The host responds to ping and its TCP ports 8080/8443 are now
open. HTTP redirects to HTTPS. The presented main-edge certificate is
self-signed and not yet trusted by Prateek's client, so the main-edge HTTP
response/upstream path is not yet verified. Its configured upstream pool is
Backend A at `10.7.28.39:3001` and Backend B at `10.7.18.197:3002`. Prateek's
standby nginx uses the same upstreams and has been verified on HTTP `8080` and
HTTPS `8443`; HTTP redirects to HTTPS.

Prateek's `en0` address, `/20` mask, gateway, and primary DNS service were
checked locally. Sarthak's latest report records `en0` as `10.7.18.197/19`
with gateway `10.7.0.1`; this differs from the expected `/20` and needs team
confirmation. Sankalp's host was pingable, but its interface/mask were not
independently checked from that laptop.

## Service matrix

| Service | Host | Address/port | State |
|---|---|---|---|
| Primary DNS | Prateek | `10.7.28.39:53` UDP/TCP | Running; local DNS queries verified |
| Main edge | Sankalp | `10.7.26.113:8080/8443` | TCP open; HTTP redirects; HTTPS cert is self-signed and not yet trusted by Prateek |
| Backend A | Prateek | `10.7.28.39:3001` | Managed by project scripts |
| Backend B | Sarthak | `10.7.18.197:3002` | Remote HTTP 200 / `X-Backend: B`; standby pool alternates A/B |
| Backup DNS | Sarthak | `10.7.18.197:53` UDP/TCP | UDP times out; TCP connection resets from Prateek |
| Standby edge | Prateek | `10.7.28.39:8080/8443` | Local HTTPS works; `X-Edge: standby` |

No DNS cutover or coordinated failure test should be inferred from this diagram.
See the follow-up audit logs in `evidence/phase2/prateek/logs/`.
