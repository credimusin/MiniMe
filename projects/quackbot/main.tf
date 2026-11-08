locals {
  bot_username = "duck"
  bot_password = sha256("minime-${local.bot_username}:${var.registration_token}")
  source_files = fileset(var.source_dir, "{index.mjs,package.json,src/**/*.mjs,assets/*}")

  entrypoint_script = <<-EOT
    #!/bin/sh
    set -u
    sleep 5
    mkdir -p /app/data
    while true; do
      node /app/index.mjs
      SLEEP_SEC=$(cat /tmp/next_sleep 2>/dev/null || echo 3600)
      sleep "$${SLEEP_SEC}"
    done
  EOT
}

resource "docker_volume" "quackbot_data" {
  name = "minime_quackbot_data"
}

resource "docker_container" "quackbot" {
  name           = "minime-quackbot"
  image          = var.image_id
  restart        = "unless-stopped"
  remove_volumes = false

  entrypoint = ["/usr/local/bin/quackbot-entrypoint.sh"]

  volumes {
    volume_name    = docker_volume.quackbot_data.name
    container_path = "/app/data"
  }

  env = [
    "TZ=Europe/Moscow",
    "HOMESERVER_URL=${var.homeserver_url}",
    "SERVER_NAME=${var.server_name}",
    "ADMIN_USERNAME=${var.admin_username}",
    "REGISTRATION_TOKEN=${var.registration_token}",
    "BOT_USERNAME=${local.bot_username}",
    "HNBOT_PASSWORD=${local.bot_password}",
    "MIN_SCORE=${var.min_score}",
    "DB_PATH=/app/data/quackbot.db",
  ]

  dynamic "upload" {
    for_each = local.source_files
    content {
      file        = "/app/${upload.value}"
      source      = "${var.source_dir}/${upload.value}"
      source_hash = filesha256("${var.source_dir}/${upload.value}")
    }
  }

  upload {
    file       = "/usr/local/bin/quackbot-entrypoint.sh"
    content    = local.entrypoint_script
    executable = true
  }

  networks_advanced {
    name    = var.ingress_network_name
    aliases = ["quackbot"]
  }
}
