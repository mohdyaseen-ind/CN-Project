# Final Presentation Outline

Draft slide plan for the team's final deck. Keep result labels aligned with the
integrated report and evidence index; convert pending rows to results only
after the corresponding test runs.

1. **Title and team roles** — Project, course, names, and three assigned host
   roles.
2. **Topology** — Three-laptop diagram, DNS servers, main/standby edges, and
   backend placement. Note the `/19` versus expected `/20` mask discrepancy.
3. **Request path** — Client DNS → TCP → TLS/SNI → nginx → backend → response;
   identify ports 53, 8080, 8443, 3001, and 3002.
4. **DNS and LAN evidence** — Host addresses, primary answers/TTL/forwarding,
   backup dnsmasq config/firewall audit, and pending local/LAN/remote checks.
5. **Main edge and TLS** — Project nginx config, HTTP redirect, certificate
   SANs, TLS 1.2/1.3, HTTP/1.1 and HTTP/2. State that system/browser trust is
   still pending.
6. **Backends and load balancing** — Backend implementation and actual A/B
   headers through the main edge; note remote status checks.
7. **HTTP caching** — Cache-Control, ETag, and actual conditional 304 result.
8. **Firewall/service isolation** — Prepared PF rules and rollback, syntax
   results, active-state access limit, and the tests still pending.
9. **Phase 2 extensions** — One status panel for A–F. Separate verified
   baseline from unrun coordinated DNS failover, TTL, isolation, HA, migration,
   and troubleshooting practice.
10. **Evidence, limitations, and close** — Logs, current screenshot/pcap
    inventory, primary edge single point of failure, subnet discrepancy, next
    coordination actions, and lessons learned.

Use actual screenshots and packet captures from the role evidence folders. Do
not use old screenshots from a different port/certificate setup as current
proof. The current packet capture and final browser trust evidence are pending.
