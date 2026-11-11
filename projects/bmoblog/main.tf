locals {
  http_port = 80

  posts_files   = try(fileset("${var.source_dir}/posts", "**"), [])
  scripts_files = try(fileset("${var.source_dir}/scripts", "**"), [])
  public_files  = try(fileset("${var.source_dir}/public", "**"), [])

  app_files = toset(concat(
    [for f in local.posts_files : "posts/${f}" if !startswith(f, ".")],
    [for f in local.scripts_files : "scripts/${f}" if !startswith(f, ".")],
    [for f in local.public_files : "public/${f}" if !startswith(f, ".")]
  ))
}

resource "docker_image" "node" {
  name         = "docker.io/library/node:${var.image_tag}"
  keep_locally = true
}

resource "docker_volume" "bmoblog_data" {
  name = "minime_imaginaldev_data"

  lifecycle {
    prevent_destroy = true
  }
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
    for f in local.app_files : filesha256("${var.source_dir}/${f}")
  ]))
}

resource "docker_container" "bmoblog" {
  name           = "minime-bmoblog"
  image          = docker_image.node.image_id
  restart        = "unless-stopped"
  remove_volumes = false
  working_dir    = "/app"
  command        = ["node", "scripts/server.mjs"]

  env = [
    "PORT=${local.http_port}",
    "NODE_ENV=production",
  ]

  lifecycle {
    replace_triggered_by = [
      terraform_data.build,
      terraform_data.content_hash,
    ]
  }

  volumes {
    volume_name    = docker_volume.bmoblog_data.name
    container_path = "/app/data"
  }

  dynamic "upload" {
    for_each = local.app_files
    content {
      file   = "/app/${upload.value}"
      source = "${var.source_dir}/${upload.value}"
    }
  }

  networks_advanced {
    name    = var.ingress_network_name
    aliases = ["bmoblog"]
  }

  healthcheck {
    test         = ["CMD-SHELL", "wget -qO- http://127.0.0.1:${local.http_port}/ >/dev/null"]
    interval     = "15s"
    timeout      = "5s"
    retries      = 3
    start_period = "5s"
  }
}
