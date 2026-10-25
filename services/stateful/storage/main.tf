resource "docker_volume" "forgejo_data" {
  name = "minime_forgejo_data"

  lifecycle {
    prevent_destroy = true
  }
}

resource "docker_volume" "forgejo_config" {
  name = "minime_forgejo_config"

  lifecycle {
    prevent_destroy = true
  }
}

resource "docker_volume" "caddy_data" {
  name = "minime_caddy_data"

  lifecycle {
    prevent_destroy = true
  }
}

resource "docker_volume" "caddy_config" {
  name = "minime_caddy_config"

  lifecycle {
    prevent_destroy = true
  }
}
