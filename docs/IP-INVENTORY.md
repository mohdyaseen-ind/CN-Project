# IP Inventory

Addresses and interface details below distinguish direct local observations
from teammate reports. The assigned addresses are inside the expected subnet,
but the reported prefix lengths differ and must be reconciled with the
team/network administrator before asserting all three machines share the same
prefix.

| Member | Role | Assigned IPv4 | Interface | Verification/source |
|---|---|---:|---|---|
| Prateek | Primary DNS, Backend A, standby nginx | `10.7.28.39/20` | `en0` | Directly verified; gateway `10.7.0.1` |
| Sankalp | Backup DNS, main nginx, HTTPS/load balancing | `10.7.26.113/19` (reported) | `en0` | Sankalp host report verifies address, `/19`, and gateway `10.7.0.1`; main-edge baseline passes locally, but its self-signed cert is not trusted by Prateek |
| Sarthak | Backend B, test client/Wireshark | `10.7.18.197/19` (reported) | `en0` | Sarthak report records `/19`; Backend B passes from Sankalp but Prateek's latest probe got an empty reply; ping from Prateek timed out |

## Prateek's observed network

- Interface: `en0` (active)
- IPv4/netmask: `10.7.28.39/20` (`255.255.240.0`)
- Broadcast: `10.7.31.255`
- Default gateway: `10.7.0.1`
- Expected shared subnet: `10.7.16.0/20`

## Subnet discrepancy

The project expects `10.7.16.0/20` (`255.255.240.0`). Prateek reports `/20`,
while Sankalp and Sarthak report `/19` (`255.255.224.0`). All assigned host IPs
fall inside the expected `10.7.16.0/20` address range, but their configured
prefix lengths differ. All three reports list gateway `10.7.0.1`. Confirm the
intended LAN mask with the team/network administrator before changing shared
network configuration or claiming identical subnet configuration.

The reported `/19` on Sankalp and Sarthak includes the assigned hosts but is
broader than the documented `/20`. No peer MAC addresses are included in this
inventory.
