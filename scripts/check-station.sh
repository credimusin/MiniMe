#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CHECK_FILE="${WORKSPACE_ROOT}/.last_healthcheck"

ssh -q monster 'bash -s' < "${SCRIPT_DIR}/station-healthcheck.sh"
date +%Y-%m-%d > "${CHECK_FILE}"
