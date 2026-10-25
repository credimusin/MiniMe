#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "==> [1/5] Checking for accidentally tracked secrets, state, private docs, or IP addresses..."
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  FORBIDDEN_PATTERN='(\.tfvars$|\.tfvars\.json$|\.tfstate$|\.tfstate\..*|\.tfplan$|^tfplan$|\.pem$|\.key$|\.pfx$|\.p12$|\.age$|^id_rsa|^id_ed25519|^secrets/|^\.env$|\.sql$|\.sql\.gz$|\.dump$|\.bak$|^backups/|^AGENTS\.md$|^KNOWN_ISSUES\.md$)'
  FORBIDDEN_FILES="$(git ls-files | grep -E "$FORBIDDEN_PATTERN" || true)"
  if [[ -n "$FORBIDDEN_FILES" ]]; then
    echo "ERROR: Forbidden sensitive/state/private files are tracked in git:"
    echo "$FORBIDDEN_FILES"
    exit 1
  fi

  LEAKED_IPS="$(git grep -E -o '([0-9]{1,3}\.){3}[0-9]{1,3}' -- ':!.terraform.lock.hcl' | grep -vE '(127\.0\.0\.1|0\.0\.0\.0)' || true)"
  if [[ -n "$LEAKED_IPS" ]]; then
    echo "ERROR: Hardcoded IPv4 address detected in tracked files:"
    echo "$LEAKED_IPS"
    exit 1
  fi
fi

echo "==> [2/5] Checking OpenTofu HCL formatting (tofu fmt)..."
tofu fmt -check -diff -recursive

echo "==> [3/5] Initializing OpenTofu modules & providers (backend=false)..."
tofu init -backend=false -input=false >/dev/null

echo "==> [4/5] Validating OpenTofu configuration (tofu validate)..."
tofu validate

echo "==> [5/5] Running TFLint static analysis (tflint --recursive)..."
tflint --init >/dev/null
tflint --recursive

echo "==> All CI checks passed successfully!"
