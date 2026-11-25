# Sankalp Viva Preparation

Use these as short spoken prompts; tie every answer to the project's configs
and observed evidence.

1. Trace `app.team1.test` from client DNS lookup to the backend response.
2. Why does the edge terminate TLS, and how do SNI and SAN hostname validation
   work for the two project domains?
3. What is the difference between TCP reachability and a successful HTTPS
   request?
4. How does nginx select upstreams by default, and what do `max_fails` and
   `fail_timeout` observe?
5. Which requests can `proxy_next_upstream` safely retry, and why might a client
   still observe a failed request during backend failure?
6. How do `X-Forwarded-For`, `X-Forwarded-Proto`, and `Host` help the backend?
7. How does the response retain `X-Backend` while the edge adds `X-Edge`?
8. What does `Cache-Control: max-age=60` tell a cache, and how does `ETag` enable
   a conditional `304 Not Modified` response?
9. Why does querying a DNS server with `dig @server` not prove the system
   resolver's cached answer or failover behavior?
10. What does a 30-second DNS TTL guarantee, and what does it not guarantee
    during an edge migration?
11. How would you distinguish DNS, TCP, TLS, HTTP routing, and backend failures
    using the diagnostic script?
12. What is the primary edge single point of failure, and what additional
    mechanism would be needed to remove it?
13. How are private TLS keys protected, and what exactly may be shared with
    teammates?
14. Which tests require coordination or administrator authorization, and what
    rollback state is recorded before each one?
15. Which Phase 2 claims are supported by actual test evidence today, and which
    remain pending? Explain without treating a configuration file as proof of
    runtime behavior.
