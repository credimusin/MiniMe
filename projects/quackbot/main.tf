locals {
  bot_password = sha256("minime-hnbot:${var.registration_token}")
  bot_script   = "${var.source_dir}/index.mjs"
  has_script   = fileexists(local.bot_script)

  entrypoint_script = <<-EOT
    #!/bin/sh
    set -u
    sleep 5
    while true; do
      node /usr/local/bin/quackbot.mjs
      SLEEP_SEC=$(cat /tmp/next_sleep 2>/dev/null || echo 3600)
      sleep "$${SLEEP_SEC}"
    done
  EOT
}

resource "docker_container" "quackbot" {
  name           = "minime-quackbot"
  image          = var.image_id
  restart        = "unless-stopped"
  remove_volumes = false

  entrypoint = ["/usr/local/bin/quackbot-entrypoint.sh"]

  env = [
    "TZ=Europe/Moscow",
    "HOMESERVER_URL=${var.homeserver_url}",
    "SERVER_NAME=${var.server_name}",
    "ADMIN_USERNAME=${var.admin_username}",
    "REGISTRATION_TOKEN=${var.registration_token}",
    "HNBOT_PASSWORD=${local.bot_password}",
    "MIN_SCORE=${var.min_score}",
  ]

  dynamic "upload" {
    for_each = local.has_script ? [local.bot_script] : []
    content {
      file        = "/usr/local/bin/quackbot.mjs"
      source      = upload.value
      source_hash = filesha256(upload.value)
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
