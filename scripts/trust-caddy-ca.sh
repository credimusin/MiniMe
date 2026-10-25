#!/usr/bin/env bash
# Fetches Caddy's internal Root CA from monster and imports it into local browser NSS DBs.
set -euo pipefail

TMP_CERT="$(mktemp --suffix=.crt)"
trap 'rm -f "$TMP_CERT"' EXIT

echo "==> Fetching Caddy Root CA from monster..."
ssh monster "podman exec minime-caddy cat /data/caddy/pki/authorities/local/root.crt" > "$TMP_CERT"

while IFS= read -r db_file; do
  db_dir="$(dirname "$db_file")"
  echo "==> Importing Caddy Root CA into browser NSS DB: $db_dir"
  certutil -d "sql:${db_dir}" -D -n "MiniMe Caddy Root CA" 2>/dev/null || true
  certutil -d "sql:${db_dir}" -A -t "C,," -n "MiniMe Caddy Root CA" -i "$TMP_CERT"
done < <(find "$HOME/.pki" "$HOME/.mozilla" "$HOME/.var/app" -name "cert9.db" 2>/dev/null || true)

echo "==> Done! Browser NSS databases now trust Caddy Root CA."
echo "==> To also trust it in system CLI tools (curl, git), run:"
echo "    ssh monster 'podman exec minime-caddy cat /data/caddy/pki/authorities/local/root.crt' | sudo tee /etc/pki/ca-trust/source/anchors/minime-caddy-root.crt >/dev/null && sudo update-ca-trust"
