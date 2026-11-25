# Standby TLS Setup

The standby nginx listens on HTTPS 8443 for `app.team1.test` and
`api.team1.test`; HTTP 8080 redirects to HTTPS. The nginx config enables TLS
1.2 and TLS 1.3. Its certificate and private key paths are project-local:
`edge/certs/app.crt` and `edge/certs/app.key`.

## Use the existing local certificate

This Mac already has an unexpired certificate with SANs for both hostnames,
signed by the local `Team1 Local CA`. The public certificate chain validates
locally. Its private key matches the certificate and remains local with
restrictive permissions. Do not regenerate or replace it for this test.

The local nginx script trusts `edge/certs/ca.crt` when present; for a standalone
self-signed certificate it falls back to trusting `edge/certs/app.crt`.
Before configuring another team member's client, have the team/faculty approve
the public trust certificate. Share only the appropriate `.crt` file, never
`app.key` or `ca.key`.

## Generate a new self-signed certificate only if needed

The helper refuses to overwrite an existing certificate or key:

```sh
bash configs/tls/gen-cert.sh
```

It creates a 365-day RSA certificate with SAN entries for both project names.
Keep `edge/certs/app.key` private and local. For client validation, distribute
only `edge/certs/app.crt` after approval. A self-signed certificate causes
normal browser warnings until that public certificate is explicitly trusted.

## Validate before use

```sh
openssl x509 -in edge/certs/app.crt -noout -subject -dates -ext subjectAltName
openssl verify -CAfile edge/certs/ca.crt edge/certs/app.crt
./scripts/standby-nginx.sh config-test
./scripts/standby-nginx.sh status
```

For a self-signed cert without a separate `ca.crt`, use:

```sh
openssl verify -CAfile edge/certs/app.crt edge/certs/app.crt
```

Do not install or overwrite a system-wide nginx config for this local standby.
