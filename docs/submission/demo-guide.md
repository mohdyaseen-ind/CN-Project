# Live Demonstration Guide

This is the run order, not evidence of a completed demonstration. Use the
team's current IP assignments and record timestamps, actual command output, and
the operator for every step.

## Before the demonstration

1. Confirm all three laptops are on the same `10.7.16.0/20` LAN and verify each
   active interface, address, and gateway.
2. Confirm primary and backup DNS answer both names to the primary edge; verify
   UDP and TCP DNS on port 53.
3. Confirm Backend A `:3001` and Backend B `:3002` return `/api/status`.
4. On Sankalp's laptop, run `./scripts/edge-nginx.sh config-test`, then start
   and check the main edge. Do not use a system nginx PID or global config.
5. Install the approved public certificate/CA on demonstration clients and
   verify there are no browser certificate warnings.
6. Start Sarthak's packet capture and agree on stop/recovery signals before any
   failure test. Keep a copy of rollback commands and original DNS records.

## Phase 1 request path

From Sarthak's test client, show both DNS answers, HTTPS `/`, `/api/status`, and
`/api/catalog`; show HTTP-to-HTTPS redirection, TLS version/certificate
hostname, `X-Backend`, `X-Edge: primary`, cache headers, ETag, and conditional
304. Repeat requests until both backends appear. Capture screenshots and the
packet trace without exposing private keys.

## Phase 2 sequence

1. Query backup DNS directly, then perform the agreed primary-DNS outage and
   prove the system resolver and HTTPS still work. Restore primary DNS.
2. Demonstrate 30-second cache behavior through the system resolver, wait for
   expiry, and record the explicit cache flush.
3. Show edge-to-backend access and an unauthorized direct-client denial under
   existing firewall policy.
4. Repeat HTTPS requests, coordinate Backend A stop, note failures and Backend
   B responses, restart A, and confirm both backends return.
5. Verify standby edge TLS and upstreams before changing both DNS records.
   Show cached primary versus updated standby requests (`X-Edge: standby`), then
   restore DNS and firewall state.
6. Demonstrate one controlled practice fault, diagnose by layer, repair, and
   run the same check again. Leave faculty-injected evaluation until the actual
   evaluation.

## Closeout

Verify all DNS records, services, firewall rules, and edge state were restored.
Save final logs and screenshots in the indexed evidence folders. Record any
failed requests and remaining limitations; do not describe an unrun scenario
as passed.
