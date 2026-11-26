# IP Inventory

The assigned addresses are shown with host-local observations from each role
report and Sankalp's live audit. The observed masks differ from the project
expectation and must be reconciled by the team/network administrator before
asserting all three machines share the same prefix.

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

## Subnet discrepancy

The project expects `10.7.16.0/20` (`255.255.240.0`). Prateek reports `/20`,
while Sankalp and Sarthak report `/19` (`255.255.224.0`). All assigned host IPs
fall inside the expected `10.7.16.0/20` address range, but their configured
prefix lengths differ. All three reports list gateway `10.7.0.1`. Confirm the
intended LAN mask with the team/network administrator before changing shared
network configuration or claiming identical subnet configuration.
