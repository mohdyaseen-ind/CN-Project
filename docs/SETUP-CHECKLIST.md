# Team setup checklist

## Before any service configuration

Every Mac:
- Connect to the same private Wi-Fi/LAN.
- Record IP, netmask, gateway, interface and MAC address.
- Verify all six Mac-to-Mac ping pairs.
- Fix/reserve IPs so they do not change.

## IP placeholders

Fill these in before using configs:

MAC1_IP = Sankalp / DNS
MAC2_IP = Prateek / nginx
MAC3_IP = Yaseen / Backend A
MAC4_IP = Mathapati/Sarthak / Backend B

## Homebrew

Run on every Mac:
    brew --prefix
    brew install wireshark

Sankalp:
    brew install dnsmasq

Prateek:
    brew install nginx openssl

## Phase 1 evidence

Save evidence in the numbered `evidence/` folders. The evaluator should be
able to find each item quickly.

## Safety

The configuration files came from the team's existing config ZIP and were
reorganized without changing their contents. Review IP/path placeholders
before running them.
