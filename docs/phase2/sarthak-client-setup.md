# Sarthak — Backup DNS, Backend B, Firewall & Client Setup Guide

Host: `10.7.18.197` (`en0`, subnet `/19` `255.255.224.0`, gateway `10.7.0.1`)

## 1. Backup DNS (`dnsmasq`)

- **Template:** [configs/dns/dnsmasq-backup.conf](../../configs/dns/dnsmasq-backup.conf)
- **Live system config:** `/opt/homebrew/etc/dnsmasq.conf`
- **Zone records:** `/opt/homebrew/etc/team.hosts` (matches [configs/dns/team.hosts](../../configs/dns/team.hosts))

```text
10.7.26.113 app.team1.test api.team1.test
```

### Service Management (Homebrew / Root LaunchDaemon)

Before editing `/opt/homebrew/etc/dnsmasq.conf` or `/opt/homebrew/etc/team.hosts`, back them up:

```sh
sudo cp /opt/homebrew/etc/dnsmasq.conf /opt/homebrew/etc/dnsmasq.conf.bak.$(date +%Y%m%d-%H%M%S)
sudo cp /opt/homebrew/etc/team.hosts /opt/homebrew/etc/team.hosts.bak.$(date +%Y%m%d-%H%M%S)
```

Validate syntax and manage the service:

```sh
/opt/homebrew/sbin/dnsmasq --test -C /opt/homebrew/etc/dnsmasq.conf
sudo brew services start dnsmasq
sudo brew services restart dnsmasq
sudo brew services stop dnsmasq
```

Verify listeners and local resolution:

```sh
netstat -an | grep '\.53 '
dig @127.0.0.1 app.team1.test A
dig +tcp @127.0.0.1 api.team1.test A
dig @127.0.0.1 example.com A
```

---

## 2. Backend B (`backend/server.py B 3002`)

Project-local scripts manage only Backend B using `var/run/backend-b.pid` and `var/log/backend-b.log`:

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
# Conditional 304 check using exact ETag from /api/catalog:
curl -i -H 'If-None-Match: "218f45a7f65b69a5"' http://127.0.0.1:3002/api/catalog
```

---

## 3. Client DNS & TLS Certificate Setup (Run Only After Both DNS Servers Pass Remote Verification)

### Preserve Original DNS Settings

Record current `en0` (Wi-Fi) DNS servers before changing them:

```sh
networksetup -getdnsservers Wi-Fi
```

### Configure Project DNS

```sh
sudo networksetup -setdnsservers Wi-Fi 10.7.28.39 10.7.18.197
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
scutil --dns | head -n 25
```

Restore original DNS after testing (e.g., `empty` for DHCP or the saved IPs):

```sh
sudo networksetup -setdnsservers Wi-Fi empty
```

### Trust Public TLS Certificate (With Approval)

Obtain **only** the public certificate (`ca.crt` or self-signed `app.crt`) from Sankalp/Prateek—never copy `.key` files.

1. Verify certificate details:
   ```sh
   openssl x509 -in /path/to/ca.crt -noout -subject -dates
   ```
2. Test with `curl` without `-k`:
   ```sh
   curl -i --cacert /path/to/ca.crt https://app.team1.test:8443/api/status
   ```
3. Add to macOS System Keychain (with user/admin approval) for browser & system trust:
   ```sh
   sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain /path/to/ca.crt
   ```

---

## 4. Phase 2 Service Isolation (PF Rules for Backend B)

- **Rules file:** [configs/firewall/backend-b-pf.conf](../../configs/firewall/backend-b-pf.conf)
- **Anchor:** `com.apple/cnproject/backend-b` (does not modify `/etc/pf.conf`)
- **Policy:** Allows `lo0` → `3002` and Sankalp (`10.7.26.113`) → `3002`; drops all other LAN TCP traffic to port `3002`.

Validate syntax (no root required):

```sh
/sbin/pfctl -nf configs/firewall/backend-b-pf.conf
```

Back up, activate (only after team + admin approval), and roll back:

```sh
sudo ./scripts/pf-backend-b-backup.sh
sudo /sbin/pfctl -a com.apple/cnproject/backend-b -f configs/firewall/backend-b-pf.conf
sudo /sbin/pfctl -a com.apple/cnproject/backend-b -sr
# Rollback:
sudo ./scripts/pf-backend-b-rollback.sh var/pf-backups/<BACKUP_FILE>
```
