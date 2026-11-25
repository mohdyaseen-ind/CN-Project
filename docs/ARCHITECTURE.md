# Three-Mac Architecture

```text
                         Private LAN: 10.7.16.0/20
          +----------------------+----------------------+
          |                      |                      |
  Prateek: 10.7.28.39    Sankalp: 10.7.26.113   Sarthak: 10.7.18.197
  Primary DNS :53        Backup DNS :53           test client/Wireshark
  Backend A :3001        Main nginx :8080/:8443    Backend B :3002
  Standby nginx          TLS + round-robin
          |                      |                      |
          +-- standby upstream --+-- main upstream -----+

  app.team1.test / api.team1.test -> 10.7.26.113 (current intended edge)
```

The primary DNS currently points both names at the intended Sankalp edge,
`10.7.26.113`. The host responds to ping and its TCP ports 8080/8443 are now
open. HTTP redirects to HTTPS. Sankalp reports successful local HTTPS and
upstream verification using explicit trust for the self-signed certificate;
Prateek's client does not yet trust that certificate, so this path remains
unverified from Prateek. Its configured upstream pool is
Backend A at `10.7.28.39:3001` and Backend B at `10.7.18.197:3002`. Prateek's
standby nginx uses the same upstreams and has been verified on HTTP `8080` and
HTTPS `8443`; HTTP redirects to HTTPS.

Prateek's `en0` address, `/20` mask, gateway, and primary DNS service were
checked locally. Sankalp and Sarthak report `/19` masks with gateway
`10.7.0.1`; this differs from the expected `/20` and needs administrator
confirmation. Prateek pinged Sankalp at 23:54, but Sarthak did not respond.

The backup DNS role moved from Sarthak to Sankalp. Its project configuration
passes syntax validation, but the corrected project-managed service has not
started because administrator authentication is required. An earlier process
using a relative configuration returned NXDOMAIN; restart it through the
project script, then verify both local and remote UDP/TCP answers before
claiming backup DNS availability.

## Service matrix

| Service | Host | Address/port | State |
|---|---|---|---|
| Primary DNS | Prateek | `10.7.28.39:53` UDP/TCP | Local UDP/TCP answers and TTL 30 verified; Sankalp also reports remote query success |
| Main edge | Sankalp | `10.7.26.113:8080/8443` | Project nginx 1.31.10 running; Sankalp reports local HTTPS/redirect/LB/TLS pass; Prateek's CA rejects the self-signed certificate |
| Backend A | Prateek | `10.7.28.39:3001` | HTTP 200 with `X-Backend: A` verified locally and from Sankalp |
| Backend B | Sarthak | `10.7.18.197:3002` | Sankalp and Sarthak report HTTP 200; Prateek's 23:53 probe returned an empty reply |
| Backup DNS | Sankalp | `10.7.26.113:53` UDP/TCP | Project config syntax passes; service not yet started/verified remotely; prior relative-config process returned NXDOMAIN |
| Standby edge | Prateek | `10.7.28.39:8080/8443` | Local HTTPS returns `X-Edge: standby`; Prateek's latest six requests returned A only; Sankalp reports remote HTTPS reset |

No DNS cutover or coordinated failure test should be inferred from this diagram.
See the follow-up audit logs in `evidence/phase2/prateek/logs/`.
