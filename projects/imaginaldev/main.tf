locals {
  http_port = 80

  public_dir = "${var.source_dir}/public"

  all_files = fileexists("${local.public_dir}/index.html") ? fileset(local.public_dir, "**") : toset([])

  web_files = toset([
    for f in local.all_files : f
    if !startswith(f, ".")
  ])

  nginx_site_conf = templatefile("${path.module}/templates/nginx.conf.tftpl", {
    http_port = local.http_port
  })
}

resource "docker_image" "nginx" {
  name         = "docker.io/library/nginx:${var.image_tag}"
  keep_locally = true
}

resource "terraform_data" "build" {
  triggers_replace = [
    sha256(join("", [
      for f in try(fileset("${var.source_dir}/posts", "**"), []) : filesha256("${var.source_dir}/posts/${f}")
    ])),
    fileexists("${var.source_dir}/scripts/build.mjs") ? filesha256("${var.source_dir}/scripts/build.mjs") : "",
  ]

  provisioner "local-exec" {
    command     = "node scripts/build.mjs"
    working_dir = var.source_dir
  }
}

resource "terraform_data" "content_hash" {
  input = sha256(join("", [
    for f in local.web_files : filesha256("${local.public_dir}/${f}")
  ]))
}

resource "docker_container" "imaginaldev" {
  name           = "minime-imaginaldev"
  image          = docker_image.nginx.image_id
  restart        = "unless-stopped"
  remove_volumes = false

  lifecycle {
    replace_triggered_by = [
      terraform_data.build,
      terraform_data.content_hash,
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
      source = "${local.public_dir}/${upload.value}"
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
