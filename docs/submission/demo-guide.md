# Faculty Live Demonstration — 11-Step Run Order

This is a prepared sequence derived from the requirements supplied for the
project. Run coordinated service stops, DNS mutations, and firewall changes only
after the other operators confirm READY. No unrun scenario is represented as
completed.

## Preflight

- Confirm the current host inventory, `/19` versus expected `/20` subnet
  discrepancy, gateway, and application firewall state with the team.
- Confirm Backend A/B, primary/backup DNS, main/standby nginx, and certificate
  trust are healthy. Keep saved DNS values, firewall/PF rollback state, and stop
  and restore commands available.
- Start the packet capture on Sarthak's approved interface and filter only
  project test traffic. Record timestamps and operator for each step.

## Eleven steps

1. **Show the three-host topology.** Display actual `en0` addresses/masks,
   gateways, and service/port table. Call out any unresolved prefix mismatch.
2. **Verify LAN connectivity.** Show peer pings and TCP connection checks for
   DNS, both backends, and both edges. Point out source and destination ports.
3. **Verify DNS.** Query both project names over UDP and TCP on both DNS servers;
   show TTL 30 and normal forwarding for an external name. Do not continue to
   failover unless both servers pass from the client.
4. **Verify the main HTTPS edge.** Open each domain on port 8443 with trusted
   TLS; show hostname matching, TLS 1.2/1.3, and `/` plus `/api/status`.
5. **Verify HTTP redirect and protocol.** Show port 8080 redirecting to HTTPS
   8443 and successful HTTP/1.1 and HTTP/2 where supported.
6. **Verify load balancing and cache.** Make repeated requests showing
   `X-Backend: A/B` and `X-Edge: primary`; show catalog `Cache-Control`, ETag,
   and a conditional 304.
7. **Review packet capture.** Identify DNS query/answer, TCP three-way handshake,
   source/destination ports, TLS ClientHello/ServerHello, certificate messages
   when visible, and encrypted application data. Explain TLS 1.3 visibility
   limits.
8. **Run Phase 1 controlled failures.** One at a time, with READY and rollback:
   incorrect client DNS, incorrect project record, one backend down, both
   backends down (502), and incorrect destination port. Restore and recheck
   after each fault.
9. **Demonstrate backup DNS and TTL.** Stop primary DNS only after backup is
   remotely verified; show client resolution and HTTPS, restore primary, then
   perform agreed cached/updated DNS record tests, expiry, and cache flush.
10. **Demonstrate isolation and high availability.** Show approved PF rule
    backup/active state, edge access and unauthorized direct-client denial.
    Then stop Backend A in a coordinated window, record any failed requests,
    show Backend B, restart A, and show balancing resumes.
11. **Migrate, troubleshoot, and close.** Validate standby TLS/upstreams, change
    both records to Prateek's standby edge, show cache effects and
    `X-Edge: standby`, restore records and firewall state, perform a controlled
    practice fault/repair/retest, then verify the primary system is restored.
    State the main edge single point of failure and remaining limitations.

## Closeout checklist

Confirm both DNS records point to `10.7.26.113`, primary and backup DNS are
running, both backends are healthy, primary edge is serving, original firewall
and DNS settings are restored, and logs/screenshots/pcapng files match the
evidence index. Faculty-injected troubleshooting findings stay pending until
the actual evaluation.
