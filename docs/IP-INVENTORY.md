# IP Inventory

The three addresses below are the assignments provided for the project. Only
Prateek's current host was queried directly in this session; remote assignments
remain unverified until each teammate confirms them.

| Member | Role | Assigned IPv4 | Interface | Verification/source |
|---|---|---:|---|---|
| Prateek | Primary DNS, Backend A, standby nginx | `10.7.28.39` | `en0` | Verified locally on 2026-11-25 |
| Sankalp | Main nginx, HTTPS/load balancing | `10.7.26.113` | `en0` expected | Team assignment; not verified on host |
| Sarthak | Backup DNS, Backend B, test client/Wireshark | `10.7.18.197` | `en0` expected | Team assignment; not verified on host |

## Prateek's observed network

- Interface: `en0` (active)
- IPv4/netmask: `10.7.28.39/20` (`255.255.240.0`)
- Broadcast: `10.7.31.255`
- Default gateway: `10.7.0.1`
- Expected shared subnet: `10.7.16.0/20`

The other members' gateway, netmask, and hardware addresses have not been
collected. Confirm those values on their devices rather than copying Prateek's
observations.
