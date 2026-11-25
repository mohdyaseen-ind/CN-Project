#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "$0")/../.." && pwd)"
DIR="$ROOT/edge/certs"
KEY="$DIR/app.key"
CERT="$DIR/app.crt"

if command -v brew >/dev/null 2>&1; then
    OPENSSL_PREFIX="$(brew --prefix openssl@4 2>/dev/null || brew --prefix openssl 2>/dev/null || true)"
else
    OPENSSL_PREFIX=""
fi

if [[ -n "$OPENSSL_PREFIX" && -x "$OPENSSL_PREFIX/bin/openssl" ]]; then
    OPENSSL="$OPENSSL_PREFIX/bin/openssl"
else
    OPENSSL="$(command -v openssl)"
fi

if [[ -e "$KEY" || -e "$CERT" ]]; then
    printf 'Refusing to overwrite an existing certificate or key in %s\n' "$DIR" >&2
    exit 1
fi

mkdir -p "$DIR"
umask 077
"$OPENSSL" req -x509 -newkey rsa:2048 -nodes -sha256 -days 365 \
    -keyout "$KEY" -out "$CERT" \
    -subj "/CN=app.team1.test" \
    -addext "subjectAltName=DNS:app.team1.test,DNS:api.team1.test" \
    -addext "extendedKeyUsage=serverAuth"
chmod 600 "$KEY"
chmod 644 "$CERT"
"$OPENSSL" x509 -in "$CERT" -noout -subject -ext subjectAltName -dates
printf 'Keep %s private. Share only %s (or an approved public CA certificate).\n' "$KEY" "$CERT"
