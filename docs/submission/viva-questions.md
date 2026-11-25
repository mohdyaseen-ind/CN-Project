# Viva Preparation — Questions and Short Answers

| Topic | Question | Short answer |
|---|---|---|
| DNS | What happens when a client requests `app.team1.test`? | The resolver asks a DNS server for an A record; the project DNS returns the current edge IPv4 with the configured TTL. |
| DNS | Why test DNS over both UDP and TCP? | Normal queries usually use UDP, while truncated responses and some larger exchanges use TCP; both listeners must work. |
| DNS cache | What does a 30-second TTL mean? | A cache may reuse the answer for up to 30 seconds; it does not force every client to re-query at exactly 30 seconds. |
| TCP | What does the three-way handshake prove? | SYN, SYN-ACK, ACK shows a TCP connection was established between the observed source and destination endpoints. It does not prove the application protocol works. |
| TLS | What do SNI and SAN do? | SNI tells the server which hostname the client wants; SAN lists certificate names the client checks against the requested hostname. |
| TLS | How can a self-signed certificate be trusted? | The client must explicitly trust the certificate or its local CA. `curl -k` skips verification and is not valid final evidence. |
| HTTP | Why does port 8080 redirect to 8443? | The cleartext HTTP listener returns a 301 with an HTTPS URL, moving the client to the TLS listener. |
| HTTP/2 | How was HTTP/2 confirmed? | The client reports negotiated HTTP version 2 after TLS ALPN; HTTP/1.1 can be forced separately for comparison. |
| Caching | What do Cache-Control and ETag do? | Cache-Control defines freshness policy; ETag identifies a representation so a client can ask whether it changed. |
| Caching | Why does a conditional request return 304? | The client's `If-None-Match` value matches the current ETag, so the server indicates the cached body is still current and sends no new body. |
| Load balancing | How does nginx choose a backend here? | The upstream uses nginx's default round-robin order; `X-Backend` makes each selected service visible in the response. |
| Failover | What do `max_fails` and `fail_timeout` mean? | They provide passive failure accounting: after a configured number of unsuccessful attempts within the window, nginx temporarily treats that peer as unavailable. |
| Firewall | How is service isolation demonstrated safely? | Back up the current rules, allow only approved sources plus loopback, test edge access and unauthorized direct access, then restore and verify the original rules. |
| Troubleshooting | How do you locate a failed HTTPS request? | Check DNS, then TCP connectivity, TLS handshake and hostname trust, HTTP status/headers, and finally upstream reachability and nginx logs. |
| Limitations | What remains a single point of failure? | The primary nginx host remains a single point unless the standby edge is validated and migration or another failover mechanism is demonstrated. |

Answer from observed evidence. For this run, Sankalp's edge and both backend
HTTP endpoints are verified; backup DNS, standby TLS, system client trust, and
coordinated failure/migration demonstrations remain pending.
