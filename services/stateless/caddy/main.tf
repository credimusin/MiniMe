locals {
  tls_directive = var.tls_internal ? "tls internal" : ""

  placeholder_html = file("${path.module}/templates/placeholder.html")

  caddyfile = templatefile("${path.module}/templates/Caddyfile.tftpl", {
    base_domain         = var.base_domain
    tls_directive       = local.tls_directive
    forgejo_upstream    = var.forgejo_upstream
    innerlight_upstream = var.innerlight_upstream
  })
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

  env = [
    "GODEBUG=tlsmlkem=0,tlssecpmlkem=0",
  ]

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

  ports {
    internal = 443
    external = 443
    protocol = "udp"
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

  upload {
    file    = "/srv/placeholder/index.html"
    content = local.placeholder_html
  }

  networks_advanced {
    name = var.ingress_network_name
    aliases = [
      "caddy",
      var.base_domain,
      "www.${var.base_domain}",
      "forgejo.${var.base_domain}",
      "innerlight.${var.base_domain}",
    ]
  }

  healthcheck {
    test         = ["CMD-SHELL", "wget -qO- http://127.0.0.1:2019/config/ >/dev/null"]
    interval     = "15s"
    timeout      = "5s"
    retries      = 3
    start_period = "10s"
  }
}
