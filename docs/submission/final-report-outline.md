# Final Report Outline — Private Network Service Platform

> Draft structure only. Replace each pending marker with measured evidence and
> results from the responsible laptop before submission.

## 1. Summary and team roles

Describe Prateek (`10.7.28.39`), Sankalp (`10.7.26.113`), and Sarthak
(`10.7.18.197`) with each machine's verified interface and services.

## 2. Architecture and request flow

```text
Client -> primary/backup DNS -> edge TCP :8443 -> TLS/SNI
       -> main nginx -> round-robin Backend A :3001 / Backend B :3002
       <- HTTP response with X-Backend and X-Edge headers
```

Insert the verified topology diagram, IP/interface/subnet/gateway inventory,
and actual DNS, TCP, TLS, and HTTP observations.

## 3. Phase 1 implementation and results

Include DNS records/TTL and forwarding, nginx configuration, backend source,
TLS certificate setup, firewall policy and rollback, and the integrated request
path. Link each result to its command log, screenshot, or packet capture.

## 4. Phase 2 changes and results

For each extension, report implementation, test method, actual output, outcome,
evidence path, and one learning-summary paragraph:

1. Backup DNS failover — pending Sankalp service start and remote verification by Prateek and Sarthak.
2. DNS TTL and cache — pending cache-aware system resolver evidence.
3. Service isolation — pending authorized edge/backend and client checks.
4. High availability — pending coordinated Backend A failure and recovery.
5. Edge migration — pending trusted standby and coordinated DNS cutover/rollback.
6. Troubleshooting — pending controlled practice fault and repair.

## 5. Troubleshooting findings

Record symptom, affected layer, diagnostic evidence, root cause, repair, and
verification. Keep faculty-injected evaluation findings blank until performed.

## 6. Limitations and single points of failure

Discuss any remaining unverified links, client trust requirements, DNS/cache
behavior, and the primary edge as a single point of failure unless migration or
another redundancy mechanism is demonstrated.

## 7. Evidence index and appendices

List all logs, screenshots, packet captures, configuration snapshots, and
rollback instructions. Identify the operator and capture date for each item.
