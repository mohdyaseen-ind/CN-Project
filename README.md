# Private Network Service Platform

A Computer Networks course project focused on designing, implementing and testing a private network service infrastructure using macOS laptops connected over a local area network (LAN).

The project is divided into two phases:

- **Phase 1 — Build and Observe:** Establishing the core networking infrastructure using four laptops.
- **Phase 2 — Harden and Recover:** Extending the infrastructure with security, redundancy and fault recovery using three laptops.

---

# Phase 1 — Build and Observe

## Overview

Phase 1 focuses on establishing a functional private network that demonstrates DNS resolution, HTTPS communication, reverse proxy, load balancing, backend services, HTTP caching and network packet analysis.

The infrastructure was distributed across four macOS laptops.

## Team Members and Responsibilities

| Member | Machine | Responsibility |
|---|---|---|
| Sankalp | Mac 1 | Primary DNS Server and Wireshark |
| Prateek | Mac 2 | nginx Reverse Proxy, HTTPS/TLS and Load Balancing |
| Mohammed Yaseen | Mac 3 | Backend A |
| Sarthak Mathapati | Mac 4 | Backend B and Test Client |

## Network Architecture

```text
                  Client
                     |
                     v
               Private DNS
                 Sankalp
                     |
              DNS Resolution
                     |
                     v
             nginx Reverse Proxy
                 Prateek
               HTTPS / TLS
                     |
              Load Balancing
               /          \
              v            v
         Backend A      Backend B
           Yaseen        Sarthak
          Port 3001     Port 3002
```

## Implementation

### 1. Private LAN Configuration

- Established a local network connecting four macOS laptops.
- Identified machine IP addresses, network interfaces and gateways.
- Performed network connectivity tests using ping.
- Documented the network topology and machine responsibilities.

### 2. Private DNS Server

- Configured dnsmasq on Sankalp's Mac.
- Established private domain records for `app.team1.test` and `api.team1.test`.
- Configured domain resolution to Prateek's nginx edge server.
- Tested DNS resolution using dig.

### 3. Backend Application Services

Implemented two Python-based backend application servers.

| Backend | Member | Port |
|---|---|---|
| Backend A | Mohammed Yaseen | 3001 |
| Backend B | Sarthak Mathapati | 3002 |

Application endpoints:

- `/` — Basic application response.
- `/api/status` — Backend identity and service status.
- `/api/catalog` — Catalog data with caching support.

The `X-Backend` response header identifies the backend serving each request.

### 4. Reverse Proxy and Load Balancing

- Configured nginx on Prateek's Mac.
- Implemented round-robin load balancing.
- Distributed incoming requests between Backend A and Backend B.
- Verified backend identification through HTTP response headers.

### 5. HTTPS and TLS

- Generated local TLS certificates using OpenSSL.
- Configured secure HTTPS communication.
- Implemented HTTP-to-HTTPS redirection.
- Established TLS termination at the nginx reverse proxy.

### 6. HTTP Caching

Implemented HTTP caching using:

- Cache-Control
- ETag
- If-None-Match
- HTTP 304 Not Modified

These mechanisms reduce unnecessary data transmission and improve communication efficiency.

### 7. Network Packet Analysis

Used Wireshark to observe network communication, including:

- DNS resolution.
- TCP connection establishment.
- TLS handshake.
- Certificate information.
- Encrypted application traffic.

### 8. Controlled Failure Scenarios

The Phase 1 evidence includes demonstrations of:

- Incorrect DNS server configuration.
- Incorrect DNS records.
- Backend A failure.
- Both backends becoming unavailable.
- Incorrect destination port.

## Phase 1 Outcome

Phase 1 established the foundational networking infrastructure using four distributed machines and demonstrated the interaction between DNS, TCP, TLS, HTTP, reverse proxy and backend application services.

The original Phase 1 evidence is preserved in the repository.

---

# Phase 2 — Harden and Recover

## Overview

Phase 2 extends the existing infrastructure with security, redundancy, high availability and controlled failure recovery.

The architecture was reorganized from four laptops to three laptops. Mohammed Yaseen was part of the Phase 1 architecture, while Phase 2 operates with Prateek, Sankalp and Sarthak.

The existing responsibilities were redistributed without introducing additional physical machines.

## Updated Team Members and Responsibilities

| Member | IP Address | Responsibility |
|---|---|---|
| Prateek | 10.7.28.39 | Primary DNS, Backend A, Standby nginx |
| Sankalp | 10.7.26.113 | Backup DNS, Main nginx, HTTPS and Load Balancing |
| Sarthak Mathapati | 10.7.18.197 | Backend B, Test Client and Wireshark |

## Changes from Phase 1

| Component | Phase 1 | Phase 2 |
|---|---|---|
| Physical Machines | 4 | 3 |
| Primary DNS | Sankalp | Prateek |
| Backup DNS | Not assigned | Sankalp |
| Main Reverse Proxy | Prateek | Sankalp |
| Backend A | Yaseen | Prateek |
| Backend B | Sarthak | Sarthak |
| Standby nginx | Not assigned | Prateek |
| Packet Analysis | Sankalp | Sarthak |

## Updated Network Architecture

```text
                      Client
                         |
                  DNS Resolution
                  /            \
                 v              v
           Primary DNS      Backup DNS
              Prateek         Sankalp
           10.7.28.39      10.7.26.113
                         |
                         v
                  Main nginx Edge
                      Sankalp
                 HTTPS Port 8443
                         |
                   Load Balancing
                   /           \
                  v             v
              Backend A      Backend B
               Prateek        Sarthak
              Port 3001      Port 3002

               Standby nginx
                   Prateek
               HTTPS Port 8443
```

## Network Configuration

| Parameter | Configuration |
|---|---|
| Primary Domain | app.team1.test |
| Secondary Domain | api.team1.test |
| Network Interface | en0 |
| DNS Port | 53 TCP/UDP |
| HTTP Port | 8080 |
| HTTPS Port | 8443 |
| Backend A Port | 3001 |
| Backend B Port | 3002 |
| DNS TTL | 30 seconds |

## Phase 2 Extensions

### Extension A — Backup DNS Resolver

Configured a secondary DNS resolver to provide redundancy during primary DNS failure.

The backup DNS was initially assigned to Sarthak but was subsequently reassigned to Sankalp due to managed macOS firewall restrictions.

Both DNS servers are intended to maintain identical domain records.

**Verification status:** Backup configuration prepared. Correct remote resolution and coordinated DNS failover verification remain pending.

### Extension B — DNS TTL and Cache Management

Configured a DNS TTL of 30 seconds to support controlled DNS record updates and service migration.

The demonstration covers:

- DNS record caching.
- Controlled record modification.
- TTL expiration.
- Manual DNS cache flushing.
- Updated DNS resolution.

**Verification status:** TTL configuration verified. Controlled expiration and record-change demonstrations remain pending.

### Extension C — Backend Service Isolation

Prepared macOS Packet Filter (PF) firewall rules to restrict unauthorized access to backend services.

The firewall policy is designed to allow backend access from the authorized nginx edge while restricting direct client connections.

Backup and rollback procedures are included to ensure safe configuration restoration.

**Verification status:** Firewall configurations prepared. Activation and verification require administrator authorization.

### Extension D — High Availability

Configured nginx with passive backend failure detection and upstream retry mechanisms.

The demonstration involves:

1. Verifying both backend services.
2. Stopping Backend A.
3. Verifying continued service through Backend B.
4. Restarting Backend A.
5. Confirming restored load balancing.

**Verification status:** Load balancing and Backend A startup verified. Complete outage-stage evidence remains pending.

### Extension E — Controlled Edge Migration

Configured a standby nginx reverse proxy on Prateek's Mac.

The standby server provides an alternative application entry point through controlled DNS-based migration.

The `X-Edge` response header identifies whether a request is handled by the primary or standby edge.

**Verification status:** Standby nginx verified locally. Complete remote migration testing remains pending.

### Extension F — Systematic Troubleshooting

Established a structured approach to diagnosing network failures.

| Component | Diagnostic Tool |
|---|---|
| LAN Connectivity | ping |
| DNS Resolution | dig |
| TCP Connectivity | nc |
| TLS Verification | OpenSSL |
| HTTP Communication | curl |
| Packet Analysis | Wireshark |

Implementation challenges include managed firewall restrictions, DNS configuration errors, TLS certificate trust and intermittent backend connectivity.

## Phase 2 Outcome

The infrastructure was successfully reorganized into a three-machine architecture. Core services, backend communication, primary DNS, load balancing and local standby HTTPS have been verified.

Additional resilience configurations have been prepared, with coordinated failure testing and evidence collection required to establish complete Phase 2 functionality.

---

## Technology Stack

| Technology | Purpose |
|---|---|
| Python | Backend application services |
| dnsmasq | Private DNS resolution |
| nginx | Reverse proxy and load balancing |
| OpenSSL | TLS certificate management |
| macOS PF | Network security and service isolation |
| Wireshark | Network packet analysis |
| curl | HTTP and HTTPS verification |
| dig | DNS verification |
| Git and GitHub | Version control |

## Repository Structure

```text
CN-Project/
├── backend/
├── configs/
│   ├── dns/
│   ├── edge/
│   ├── firewall/
│   └── tls/
├── scripts/
├── docs/
│   ├── phase2/
│   └── submission/
├── evidence/
│   ├── 01-lan/
│   ├── 02-dns/
│   ├── 03-lb/
│   ├── 04-tls/
│   ├── 05-caching/
│   ├── 06-wireshark/
│   ├── 07-failures/
│   └── phase2/
│       ├── prateek/
│       ├── sankalp/
│       └── sarthak/
└── README.md
```

## Evidence and Documentation

The repository preserves Phase 1 evidence separately from Phase 2 evidence.

Evidence formats include:

- PNG screenshots for practical demonstrations.
- TXT files for terminal verification logs.
- Network packet captures for protocol analysis.
- Markdown documentation for configurations and technical reports.

## Conclusion

The Private Network Service Platform demonstrates the practical application of computer networking concepts through a locally deployed distributed infrastructure.

Phase 1 established the foundational network using four laptops, while Phase 2 reorganized the system into three laptops and introduced mechanisms for security, redundancy, high availability and controlled recovery.

The project provides practical experience in network architecture, distributed services, secure communication and systematic troubleshooting without relying on external cloud infrastructure.