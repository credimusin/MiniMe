#!/usr/bin/env bash
# scripts/check-station.sh
# Local runner for remote non-destructive station health inspection.
# Records the execution date in .last_healthcheck to track daily checks.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CHECK_FILE="${WORKSPACE_ROOT}/.last_healthcheck"

# Execute healthcheck script on Monster over SSH in-memory
ssh -q monster 'bash -s' < "${SCRIPT_DIR}/station-healthcheck.sh"

# Update daily checkpoint
date +%Y-%m-%d > "${CHECK_FILE}"
