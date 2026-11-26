# Three-Mac Architecture

```text
                         Private LAN: 10.7.16.0/20
          +----------------------+----------------------+
          |                      |                      |
  Prateek: 10.7.28.39    Sankalp: 10.7.26.113   Sarthak: 10.7.18.197
  Primary DNS :53        Backup DNS :53          Backend B :3002
  Backend A :3001        Main nginx :8080/:8443   test client/Wireshark
  Standby nginx          TLS + round-robin
          |                      |                      |
          +-- standby upstream --+-- main upstream -----+

  app.team1.test / api.team1.test -> 10.7.26.113 (current intended edge)
```

Both names currently point at Sankalp's main nginx. It load-balances between
Backend A at `10.7.28.39:3001` and Backend B at
`10.7.18.197:3002`. Prateek's standby nginx uses the same upstreams but
listens on HTTP `8080` and HTTPS `8443`; the HTTP listener redirects to HTTPS.

The latest host reports record Prateek as `/20` and Sankalp and Sarthak as
`/19`; all report gateway `10.7.0.1`. The assigned IPv4 addresses fall in the
expected `10.7.16.0/20` range, but the prefix lengths differ. Confirm the
intended mask with the team/network administrator. The DNS backup role has moved
from Sarthak to Sankalp. Sankalp has dnsmasq installed, port 53 was free, and
the application firewall currently permits the dnsmasq executable; project
backup DNS configuration is prepared for local/LAN validation.

## Service matrix

| Service | Host | Address/port | State |
|---|---|---|---|
| Primary DNS | Prateek | `10.7.28.39:53` UDP/TCP | UDP/TCP answers with TTL 30 verified remotely from Sankalp; forwarding verified |
| Main edge | Sankalp | `10.7.26.113:8080/8443` | Project nginx 1.31.10 running; local HTTPS/redirect/LB/TLS verified |
| Backend A | Prateek | `10.7.28.39:3001` | Remote HTTP 200 with `X-Backend: A` from Sankalp |
| Backend B | Sarthak | `10.7.18.197:3002` | Remote HTTP 200 with `X-Backend: B` from Sankalp |
| Backup DNS | Sankalp | `10.7.26.113:53` UDP/TCP | Config syntax prepared; service start and remote verification pending administrator authorization |
| Standby edge | Prateek | `10.7.28.39:8080/8443` | Local checks in Prateek report; Sankalp's remote HTTPS reset |

No DNS cutover or coordinated failover should be inferred from this diagram.
