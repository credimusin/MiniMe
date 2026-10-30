locals {
  reconcile_sql = join("\n", [
    for db_name, cfg in var.databases : <<-EOSQL
      \connect postgres
      DO $$
      BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${cfg.user}') THEN
          CREATE ROLE "${cfg.user}" WITH LOGIN PASSWORD '${cfg.password}' NOSUPERUSER NOCREATEDB NOCREATEROLE;
        ELSE
          ALTER ROLE "${cfg.user}" WITH LOGIN PASSWORD '${cfg.password}' NOSUPERUSER NOCREATEDB NOCREATEROLE;
        END IF;
      END
      $$;

      SELECT 'CREATE DATABASE "${db_name}" OWNER "${cfg.user}"'
      WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '${db_name}')\gexec

      REVOKE ALL ON DATABASE "${db_name}" FROM PUBLIC;
      GRANT ALL PRIVILEGES ON DATABASE "${db_name}" TO "${cfg.user}";

      \connect "${db_name}"
      REVOKE ALL ON SCHEMA public FROM PUBLIC;
      GRANT ALL ON SCHEMA public TO "${cfg.user}";
    EOSQL
  ])

  reconcile_script = <<-EOT
    #!/bin/sh
    set -eu
    psql -v ON_ERROR_STOP=1 --username "${var.admin_user}" --dbname "postgres" <<'EOSQL'
    ${local.reconcile_sql}
    EOSQL
  EOT

  entrypoint_wrapper = <<-EOT
    #!/bin/sh
    set -eu

    if [ -s "$${PGDATA}/PG_VERSION" ]; then
      (
        until pg_isready -U "${var.admin_user}" -d "postgres" >/dev/null 2>&1; do
          sleep 1
        done
        /docker-entrypoint-initdb.d/00-reconcile-databases.sh
      ) &
    fi

    exec docker-entrypoint.sh "$@"
  EOT
}

resource "docker_volume" "postgres_data" {
  name = "minime_postgres_data"

  lifecycle {
    prevent_destroy = true
  }
}

resource "docker_image" "postgres" {
  name         = "docker.io/library/postgres:${var.image_tag}"
  keep_locally = true
}

resource "docker_container" "postgres" {
  name           = "minime-postgres"
  image          = docker_image.postgres.image_id
  restart        = "unless-stopped"
  remove_volumes = false

  entrypoint = ["/usr/local/bin/minime-postgres-entrypoint.sh"]
  command    = ["postgres", "-c", "log_checkpoints=off"]

  env = [
    "POSTGRES_USER=${var.admin_user}",
    "POSTGRES_PASSWORD=${var.admin_password}",
    "POSTGRES_DB=postgres",
    "PGDATA=/var/lib/postgresql/data/pgdata",
  ]

  upload {
    file       = "/docker-entrypoint-initdb.d/00-reconcile-databases.sh"
    content    = local.reconcile_script
    executable = true
  }

  upload {
    file       = "/usr/local/bin/minime-postgres-entrypoint.sh"
    content    = local.entrypoint_wrapper
    executable = true
  }

  volumes {
    volume_name    = docker_volume.postgres_data.name
    container_path = "/var/lib/postgresql/data"
  }

  networks_advanced {
    name    = var.network_name
    aliases = ["postgres"]
  }

  healthcheck {
    test         = ["CMD-SHELL", "pg_isready -U ${var.admin_user} -d postgres"]
    interval     = "10s"
    timeout      = "5s"
    retries      = 5
    start_period = "15s"
  }
}
