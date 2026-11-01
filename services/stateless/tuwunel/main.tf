locals {
  fqdn      = "${var.subdomain}.${var.base_domain}"
  http_port = 8008

  tuwunel_config = templatefile("${path.module}/templates/tuwunel.toml.tftpl", {
    fqdn               = local.fqdn
    base_domain        = var.base_domain
    http_port          = local.http_port
    max_request_size   = var.max_request_size
    registration_token = var.registration_token
    allow_federation   = var.allow_federation
  })
}

resource "docker_image" "tuwunel" {
  name         = "ghcr.io/matrix-construct/tuwunel:${var.image_tag}"
  keep_locally = true
}

resource "docker_container" "tuwunel" {
  name           = "minime-tuwunel"
  image          = docker_image.tuwunel.image_id
  restart        = "unless-stopped"
  remove_volumes = false
  user           = "0:0"

  env = [
    "TUWUNEL_CONFIG=/etc/tuwunel.toml",
  ]

  upload {
    file    = "/etc/tuwunel.toml"
    content = local.tuwunel_config
  }

  volumes {
    volume_name    = var.data_volume_name
    container_path = "/var/lib/tuwunel"
  }

  networks_advanced {
    name    = var.ingress_network_name
    aliases = ["tuwunel"]
  }

  healthcheck {
    test         = ["CMD", "tuwunel", "--health-check"]
    interval     = "15s"
    timeout      = "5s"
    retries      = 3
    start_period = "10s"
  }
}
