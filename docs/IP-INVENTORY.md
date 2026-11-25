# IP Inventory

Addresses and interface details below distinguish direct observations from
teammate-reported values. Sarthak's reported subnet mask conflicts with the
expected project subnet and needs confirmation.

| Member | Role | Assigned IPv4 | Interface | Verification/source |
|---|---|---:|---|---|
| Prateek | Primary DNS, Backend A, standby nginx | `10.7.28.39/20` | `en0` | Directly verified; gateway `10.7.0.1` |
| Sankalp | Main nginx, HTTPS/load balancing | `10.7.26.113` (assigned) | `en0` expected | Host ping and TCP 8080/8443 succeed; address/mask/gateway not verified on host; HTTPS certificate currently untrusted by Prateek |
| Sarthak | Backup DNS, Backend B, test client/Wireshark | `10.7.18.197/19` (reported) | `en0` (reported) | Reported by Sarthak; ping and Backend B HTTP verified remotely; DNS remote query fails |

## Prateek's observed network

- Interface: `en0` (active)
- IPv4/netmask: `10.7.28.39/20` (`255.255.240.0`)
- Broadcast: `10.7.31.255`
- Default gateway: `10.7.0.1`
- Expected shared subnet: `10.7.16.0/20`

Sarthak's report lists gateway `10.7.0.1` and netmask `/19`
(`255.255.224.0`), rather than expected `/20` (`255.255.240.0`). The `/19`
contains the assigned hosts but is broader than the documented subnet; have
the team confirm whether this is intended. Sankalp's mask, gateway, and all
peer MAC addresses have not been collected.
