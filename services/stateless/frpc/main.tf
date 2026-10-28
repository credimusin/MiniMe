locals {
  frpc_config = templatefile("${path.module}/templates/frpc.toml.tftpl", {
    vps_addr     = var.vps_addr
    vps_port     = var.vps_port
    auth_token   = var.auth_token
    caddy_host   = var.caddy_host
    forgejo_host = var.forgejo_host
    ssh_port     = var.ssh_port
  })
}

resource "docker_image" "frpc" {
  name         = "ghcr.io/fatedier/frpc:${var.image_tag}"
  keep_locally = true
}

resource "docker_container" "frpc" {
  name           = "minime-frpc"
  image          = docker_image.frpc.image_id
  restart        = "unless-stopped"
  remove_volumes = false
  command        = ["-c", "/etc/frp/frpc.toml"]

  upload {
    file    = "/etc/frp/frpc.toml"
    content = local.frpc_config
  }

  networks_advanced {
    name    = var.ingress_network_name
    aliases = ["frpc"]
  }
}
