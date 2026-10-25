locals {
  fqdn      = "forgejo.${var.base_domain}"
  http_port = 3000
}

resource "docker_image" "forgejo" {
  name         = "codeberg.org/forgejo/forgejo:${var.image_tag}"
  keep_locally = true
}

resource "docker_container" "forgejo" {
  name           = "minime-forgejo"
  image          = docker_image.forgejo.image_id
  restart        = "unless-stopped"
  remove_volumes = false

  env = [
    "USER_UID=1000",
    "USER_GID=1000",
    "FORGEJO__server__DOMAIN=${local.fqdn}",
    "FORGEJO__server__ROOT_URL=${var.protocol}://${local.fqdn}/",
    "FORGEJO__server__HTTP_PORT=${local.http_port}",
    "FORGEJO__server__SSH_DOMAIN=${local.fqdn}",
    "FORGEJO__server__SSH_PORT=${var.ssh_port}",
    "FORGEJO__server__SSH_LISTEN_PORT=2222",
    "FORGEJO__server__START_SSH_SERVER=true",
    "FORGEJO__database__DB_TYPE=postgres",
    "FORGEJO__database__HOST=${var.db_host}:${var.db_port}",
    "FORGEJO__database__NAME=${var.db_name}",
    "FORGEJO__database__USER=${var.db_user}",
    "FORGEJO__database__PASSWD=${var.db_password}",
    "FORGEJO__database__SSL_MODE=disable",
  ]

  ports {
    internal = 2222
    external = var.ssh_port
    protocol = "tcp"
  }

  volumes {
    volume_name    = var.data_volume_name
    container_path = "/var/lib/gitea"
  }

  volumes {
    volume_name    = var.config_volume_name
    container_path = "/etc/gitea"
  }

  networks_advanced {
    name    = var.ingress_network_name
    aliases = ["forgejo"]
  }

  networks_advanced {
    name    = var.backend_network_name
    aliases = ["forgejo"]
  }
}
