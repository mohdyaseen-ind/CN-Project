# Prateek Phase 2 Evidence Index

Command output is saved under `logs/` only after the command actually runs.
There are no placeholder PNGs. For a screenshot, first display the relevant
terminal output, then run the matching command below and select the terminal
region:

Run the matching exact command after the relevant output is visible in
Terminal. This macOS interactive capture records the selected screen region.
For coordinated tests, do not capture/create the file until that test has
actually been performed.

```sh
screencapture -i evidence/phase2/prateek/01-primary-dns.png
screencapture -i evidence/phase2/prateek/02-primary-dns-service.png
screencapture -i evidence/phase2/prateek/03-backend-a-status.png
screencapture -i evidence/phase2/prateek/04-backend-a-cache-304.png
screencapture -i evidence/phase2/prateek/05-primary-dns-stopped.png
screencapture -i evidence/phase2/prateek/06-primary-dns-restored.png
screencapture -i evidence/phase2/prateek/07-dns-ttl-before.png
screencapture -i evidence/phase2/prateek/08-dns-ttl-after.png
screencapture -i evidence/phase2/prateek/09-firewall-rules.png
screencapture -i evidence/phase2/prateek/10-edge-access-success.png
screencapture -i evidence/phase2/prateek/11-direct-access-blocked.png
screencapture -i evidence/phase2/prateek/12-backend-a-stopped.png
screencapture -i evidence/phase2/prateek/13-backend-a-restored.png
screencapture -i evidence/phase2/prateek/14-standby-nginx.png
screencapture -i evidence/phase2/prateek/15-edge-migration.png
screencapture -i evidence/phase2/prateek/16-rollback-verification.png
```

| Requested screenshot | Evidence/test | Status |
|---|---|---|
| `01-primary-dns.png` | Direct DNS answers and TTL | Query log available; screenshot pending |
| `02-primary-dns-service.png` | dnsmasq TCP/UDP listeners and process | Service log available; screenshot pending |
| `03-backend-a-status.png` | Backend A `/api/status`, HTTP 200, identity header | Local test log available; screenshot pending |
| `04-backend-a-cache-304.png` | Catalog ETag/Cache-Control and conditional 304 | Local test log available; screenshot pending |
| `05-primary-dns-stopped.png` | Coordinated primary DNS stop | Not run; Sarthak confirmation required |
| `06-primary-dns-restored.png` | Coordinated primary DNS restoration | Not run; primary DNS remains running |
| `07-dns-ttl-before.png` | Before-change DNS answer/TTL | Primary TTL query log available; coordinated mutation pending |
| `08-dns-ttl-after.png` | TTL/cache expiry after both records change | Not run; both DNS operators/client required |
| `09-firewall-rules.png` | Prepared rules and active anchor | Rules prepared; not active; admin check required |
| `10-edge-access-success.png` | Main-edge HTTPS from authorized client | Peer endpoint timed out from this Mac; team test pending |
| `11-direct-access-blocked.png` | Unauthorized direct Backend A connection blocked | Not run; firewall activation and client required |
| `12-backend-a-stopped.png` | Backend A outage | Not run; Sankalp coordination required |
| `13-backend-a-restored.png` | Backend A restored | Backend A is left running; failure cycle not begun |
| `14-standby-nginx.png` | Standby config test and local HTTPS response | Captured; screenshot shows successful config test and HTTP 200 with `X-Backend: A` and `X-Edge: standby` |
| `15-edge-migration.png` | Coordinated DNS cutover to standby and `X-Edge` | Not run; team validation/approval required |
| `16-rollback-verification.png` | DNS/firewall rollback and service verification | Not run; no migration/firewall change made |

Capture a screenshot only after the corresponding test is run successfully.
For pending coordinated tests, leave the PNG absent until the team performs the
test; do not treat an absent image as a pass.

Available actual logs: `00-peer-reachability.txt`, `01-primary-dns.txt`,
`02-primary-dns-service.txt`, `03-backend-a-status.txt`,
`04-backend-a-cache-304.txt`, `09-pf-rules-review.txt`, and
`14-standby-nginx.txt`.
