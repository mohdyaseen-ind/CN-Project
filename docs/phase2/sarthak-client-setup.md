# Client DNS and Backend B Setup Guide

Sarthak's role is Backend B (`10.7.18.197:3002`), test client, and Wireshark.
Backup DNS is hosted by Sankalp at `10.7.26.113`.

## 1. Verify both DNS servers remotely before client cutover

Run from Prateek's and Sarthak's Macs after Sankalp confirms the backup service
is running. Save the full command output and timestamp. Both transports must
return the expected answer before either client is changed.

```sh
for server in 10.7.28.39 10.7.26.113; do
  echo "=== UDP $server ==="
  dig +time=2 +tries=1 @"$server" app.team1.test A
  dig +time=2 +tries=1 @"$server" api.team1.test A
  echo "=== TCP $server ==="
  dig +tcp +time=2 +tries=1 @"$server" app.team1.test A
  dig +tcp +time=2 +tries=1 @"$server" api.team1.test A
  echo "=== forwarding $server ==="
  dig +time=2 +tries=1 @"$server" example.com A
done
```

Expected project answers are `10.7.26.113` with TTL 30. Save evidence in each
operator's role folder. Sarthak's client must report both resolvers; Prateek
must report the backup query from his own host. Do not stop primary dnsmasq
until those checks pass.

## 2. Preserve and configure client DNS

On each client, capture the current Wi-Fi configuration before changing it:

```sh
networksetup -getdnsservers Wi-Fi
scutil --dns
```

After the remote verification above succeeds, configure primary Prateek DNS and
backup Sankalp DNS, in that order:

```sh
sudo networksetup -setdnsservers Wi-Fi 10.7.28.39 10.7.26.113
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
scutil --dns | head -n 30
```

Then check the macOS system resolver and application request (these checks use
the configured client resolver, unlike `dig @server`):

```sh
dscacheutil -q host -a name app.team1.test
dscacheutil -q host -a name api.team1.test
curl --cacert /path/to/approved-public-ca.crt https://app.team1.test:8443/api/status
curl --cacert /path/to/approved-public-ca.crt https://api.team1.test:8443/api/status
```

If the previous Wi-Fi setting showed no manually configured DNS servers, restore
DHCP with:

```sh
sudo networksetup -setdnsservers Wi-Fi empty
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```

If it showed custom servers, restore that saved list instead of `empty`. Do not
install a certificate with `curl -k`; obtain approval before adding the public
CA/certificate to a macOS keychain, and never copy a private key.

## 3. Backend B (`backend/server.py B 3002`)

Project-local scripts manage only Backend B:

```sh
./scripts/backend-b-start.sh
./scripts/backend-b-status.sh
./scripts/backend-b-stop.sh
```

Local verification:

```sh
curl -i http://127.0.0.1:3002/
curl -i http://127.0.0.1:3002/api/status
curl -i http://127.0.0.1:3002/api/catalog
```

Keep Backend B available for Sankalp's main edge. Coordinate before stopping
it for failure tests.

## 4. Wireshark

Capture only the agreed project traffic. Include DNS query/answer, TCP handshake
and ports, TLS ClientHello/ServerHello, visible certificate messages, and
encrypted application data. Record that TLS 1.3 may encrypt handshake messages
after ServerHello. Save the actual `.pcapng` and matching screenshots under
`evidence/phase2/sarthak/`.
