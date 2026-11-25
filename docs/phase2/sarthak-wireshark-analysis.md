# Sarthak — Wireshark & Packet Analysis

Capture host: `10.7.18.197` (`en0`)
Capture tool: `/Applications/Wireshark.app/Contents/MacOS/dumpcap` / `tshark` / Wireshark GUI

> **Note:** All packet captures in `evidence/phase2/sarthak/` are restricted to project hosts (`10.7.28.39`, `10.7.26.113`, `10.7.18.197`) and project ports (`53`, `3001`, `3002`, `8080`, `8443`) to avoid collecting unrelated network traffic.

## Capture Commands (Filtered to Project Traffic)

```sh
# 1. DNS capture (UDP/TCP 53 to/from project DNS servers)
/Applications/Wireshark.app/Contents/MacOS/dumpcap -i en0 \
  -f "port 53 and (host 10.7.28.39 or host 10.7.18.197)" \
  -w evidence/phase2/sarthak/dns.pcapng

# 2. TCP + TLS + Complete Request Flow (to main edge 10.7.26.113:8443)
/Applications/Wireshark.app/Contents/MacOS/dumpcap -i en0 \
  -f "host 10.7.26.113 and (port 8080 or port 8443)" \
  -w evidence/phase2/sarthak/complete-request-flow.pcapng
```

## Why HTTPS Application Payloads Are Encrypted in Ordinary Wireshark Captures

When `curl` or a browser connects to `https://app.team1.test:8443`, TLS runs on top of TCP:

1. **TCP 3-way handshake (`SYN`, `SYN-ACK`, `ACK`)** happens in cleartext at Layer 4, showing source IP/ephemeral port, destination IP/`8443`, and sequence/acknowledgement numbers.
2. **TLS handshake** negotiates the protocol version (TLS 1.2 or TLS 1.3) and cipher suite via `ClientHello` and `ServerHello`, which are visible in cleartext.
   - In **TLS 1.2**, the server's `Certificate` message is also sent in cleartext.
   - In **TLS 1.3**, all handshake messages after `ServerHello` (including `EncryptedExtensions`, `Certificate`, `CertificateVerify`, and `Finished`) are **encrypted** using handshake traffic keys derived from ephemeral Diffie-Hellman (ECDHE) key exchange.
3. **HTTP Application Data (`GET /api/status`, `X-Backend`, `Cache-Control`, `ETag`, `304 Not Modified`)** is encrypted into `TLS Application Data` records using symmetric session keys (e.g., AES-GCM or ChaCha20-Poly1305) known only to the client and nginx edge. Without the server's private key (and with forward secrecy, without an explicit `SSLKEYLOGFILE` session key log), passive Wireshark captures on `en0` cannot decrypt the HTTP headers or body—so HTTP headers are verified via `curl -i` / browser DevTools.

## Observed Packet Evidence

*Pending Checkpoint 3 (requires Sankalp's main edge `10.7.26.113:8443` + public TLS certificate, and Backup DNS remote verification).*
