locals {
  caddyfile_internal = <<-EOT
    forgejo.${var.base_domain} {
      tls internal
      reverse_proxy ${var.forgejo_upstream}
    }
  EOT

  caddyfile_public = <<-EOT
    forgejo.${var.base_domain} {
      reverse_proxy ${var.forgejo_upstream}
    }
  EOT

  caddyfile = var.tls_internal ? local.caddyfile_internal : local.caddyfile_public
}

resource "docker_image" "caddy" {
  name         = "docker.io/library/caddy:${var.image_tag}"
  keep_locally = true
}

resource "docker_container" "caddy" {
  name           = "minime-caddy"
  image          = docker_image.caddy.image_id
  restart        = "unless-stopped"
  remove_volumes = false

  ports {
    internal = 80
    external = 80
    protocol = "tcp"
  }

  ports {
    internal = 443
    external = 443
    protocol = "tcp"
  }

  volumes {
    volume_name    = var.data_volume_name
    container_path = "/data"
  }

  volumes {
    volume_name    = var.config_volume_name
    container_path = "/config"
  }

  upload {
    file    = "/etc/caddy/Caddyfile"
    content = local.caddyfile
  }

  networks_advanced {
    name    = var.ingress_network_name
    aliases = ["caddy"]
  }
}
