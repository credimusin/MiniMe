#!/usr/bin/env bash
# Wrapper around `tofu` that injects secrets from `pass` into TF_VAR_* in memory.
set -euo pipefail

export TF_VAR_postgres_admin_password="${TF_VAR_postgres_admin_password:-$(pass show minime/postgres/admin | head -n 1)}"
export TF_VAR_forgejo_db_password="${TF_VAR_forgejo_db_password:-$(pass show minime/postgres/forgejo | head -n 1)}"

exec tofu "$@"
