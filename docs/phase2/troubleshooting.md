# Layer-by-Layer Troubleshooting

Run tests against the assigned service only. Do not stop services, change DNS
records, or alter firewall rules outside the team's agreed test window.

## 1. DNS

On Prateek (primary):

```sh
dig @10.7.28.39 app.team1.test A
dig @10.7.28.39 api.team1.test A
dig +tcp @10.7.28.39 app.team1.test A
dig @10.7.28.39 example.com A
```

From Sarthak's client, test both assigned DNS servers directly:

```sh
dig +time=2 +tries=1 @10.7.28.39 app.team1.test A
dig +tcp +time=2 +tries=1 @10.7.28.39 api.team1.test A
dig +time=2 +tries=1 @10.7.26.113 app.team1.test A
dig +tcp +time=2 +tries=1 @10.7.26.113 api.team1.test A
dig @10.7.26.113 example.com A
scutil --dns
```

Check the answer TTL in `dig` output. macOS resolver-cache flushing (only after
the team agrees on the TTL test) is:

```sh
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```

These flush the local resolver cache; they do not stop dnsmasq. For DNS record
reloads, coordinate both DNS operators, back up each hosts file, and use that
host's approved dnsmasq reload procedure.

## 2. TCP reachability

Check only the expected service endpoints:

```sh
nc -vz -G 3 10.7.28.39 3001
nc -vz -G 3 10.7.18.197 3002
nc -vz -G 3 10.7.26.113 8080
nc -vz -G 3 10.7.26.113 8443
```

On the service host, inspect listeners with `netstat -anv -p tcp` and verify
that the expected process is running. A timeout is a reachability failure, not
proof that a firewall rule is responsible.

## 3. TLS

Check the local standby certificate and both hostnames:

```sh
openssl s_client -connect 10.7.28.39:8443 -servername app.team1.test \
  -CAfile edge/certs/ca.crt -verify_return_error
openssl s_client -connect 10.7.28.39:8443 -servername api.team1.test \
  -CAfile edge/certs/ca.crt -verify_return_error
```

For Sankalp's main edge, first verify the self-signed certificate fingerprint
out of band with Sankalp, then use the approved public certificate as the trust
file:

```sh
openssl s_client -connect 10.7.26.113:8443 -servername app.team1.test \
  -CAfile /path/to/confirmed-main-edge.crt -verify_return_error
```

Prateek observed a self-signed main-edge certificate with both expected SANs,
but it does not chain to Prateek's current Team1 CA. Do not treat the
network-fetched fingerprint as trusted until Sankalp confirms it independently.

Use the approved public CA/certificate trust bundle on client machines. Never
copy a `.key` file or `ca.key` to another host or the repository.
If the approved certificate is self-signed rather than CA-issued, use its
public `.crt` file with `-CAfile` and with curl's `--cacert` option.

## 4. HTTP and backend identity

```sh
curl -i --resolve app.team1.test:8443:10.7.28.39 \
  --cacert edge/certs/ca.crt https://app.team1.test:8443/api/status
curl -i --resolve app.team1.test:8443:10.7.28.39 \
  --cacert edge/certs/ca.crt https://app.team1.test:8443/api/catalog
```

For the main edge, substitute `10.7.26.113` and the confirmed public
certificate path; do not use `-k`.

Record the status, `X-Edge`, `X-Backend`, cache headers, and body. For a
conditional request, copy the exact ETag from `/api/catalog`:

```sh
curl -i --resolve app.team1.test:8443:10.7.28.39 \
  --cacert edge/certs/ca.crt \
  -H 'If-None-Match: "ETAG_FROM_FIRST_RESPONSE"' \
  https://app.team1.test:8443/api/catalog
```

Expected conditional status is `304`; replace the example ETag with the actual
value, not a guessed value. Check nginx syntax with:

```sh
./scripts/standby-nginx.sh config-test
```

## Escalation

Capture the exact command and output, timestamp, source host, destination
address/port, and whether the result was a timeout or refusal. Ask the relevant
service owner to confirm their local listener and firewall state before any
policy or service change.
