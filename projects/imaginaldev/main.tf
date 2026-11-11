locals {
  http_port = 80

  excluded_files = toset([
    "README.md",
    "AGENTS.md",
    "KNOWN_ISSUES.md",
    "LICENSE",
    ".gitignore",
  ])

  all_files = fileexists("${var.source_dir}/index.html") ? fileset(var.source_dir, "**") : toset([])

  web_files = toset([
    for f in local.all_files : f
    if !contains(local.excluded_files, f)
    && !startswith(f, ".")
  ])

  nginx_site_conf = templatefile("${path.module}/templates/nginx.conf.tftpl", {
    http_port = local.http_port
  })
}

resource "docker_image" "nginx" {
  name         = "docker.io/library/nginx:${var.image_tag}"
  keep_locally = true
}

resource "terraform_data" "landing_hash" {
  input = sha256(join("", [
    for f in local.web_files : filesha256("${var.source_dir}/${f}")
  ]))
}

resource "docker_container" "landing" {
  name           = "minime-imaginaldev"
  image          = docker_image.nginx.image_id
  restart        = "unless-stopped"
  remove_volumes = false

  lifecycle {
    replace_triggered_by = [
      terraform_data.landing_hash
    ]
  }

  upload {
    file    = "/etc/nginx/conf.d/default.conf"
    content = local.nginx_site_conf
  }

  dynamic "upload" {
    for_each = local.web_files
    content {
      file   = "/usr/share/nginx/html/${upload.value}"
      source = "${var.source_dir}/${upload.value}"
    }
  }

  networks_advanced {
    name    = var.ingress_network_name
    aliases = ["imaginaldev"]
  }

  healthcheck {
    test         = ["CMD-SHELL", "wget -qO- http://127.0.0.1:${local.http_port}/ >/dev/null"]
    interval     = "15s"
    timeout      = "5s"
    retries      = 3
    start_period = "5s"
  }
}
