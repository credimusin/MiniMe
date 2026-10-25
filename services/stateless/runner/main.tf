locals {
  runner_config = <<-EOT
    log:
      level: info
    runner:
      file: /data/.runner
      capacity: 1
      timeout: 30m
      insecure: true
      envs:
        GIT_SSL_NO_VERIFY: "true"
        NODE_TLS_REJECT_UNAUTHORIZED: "0"
      labels:
        - "ubuntu-latest:docker://${var.job_image}"
    container:
      network: "${var.ingress_network_name}"
      enable_ipv6: false
      privileged: false
  EOT

  entrypoint_script = <<-EOT
    #!/bin/sh
    set -eu

    if [ ! -s /data/.runner ]; then
      echo "==> Registering Forgejo Runner with ${var.forgejo_instance_url}..."
      forgejo-runner register \
        --no-interactive \
        --instance "${var.forgejo_instance_url}" \
        --name "minime-runner" \
        --token "$${FORGEJO_RUNNER_TOKEN}" \
        --labels "ubuntu-latest:docker://${var.job_image}" \
        --config /etc/forgejo-runner/config.yml
    fi

    exec forgejo-runner daemon --config /etc/forgejo-runner/config.yml
  EOT
}

resource "docker_image" "runner" {
  name         = "data.forgejo.org/forgejo/runner:${var.image_tag}"
  keep_locally = true
}

resource "docker_image" "job_node" {
  name         = var.job_image
  keep_locally = true
}

resource "docker_container" "runner" {
  name           = "minime-runner"
  image          = docker_image.runner.image_id
  restart        = "unless-stopped"
  remove_volumes = false
  user           = "0:0"
  security_opts  = ["label=disable"]

  entrypoint = ["/usr/local/bin/minime-runner-entrypoint.sh"]

  env = [
    "DOCKER_HOST=unix:///var/run/docker.sock",
    "FORGEJO_RUNNER_TOKEN=${var.runner_token}",
  ]

  upload {
    file    = "/etc/forgejo-runner/config.yml"
    content = local.runner_config
  }

  upload {
    file       = "/usr/local/bin/minime-runner-entrypoint.sh"
    content    = local.entrypoint_script
    executable = true
  }

  volumes {
    volume_name    = var.data_volume_name
    container_path = "/data"
  }

  volumes {
    host_path      = var.podman_socket_path
    container_path = "/var/run/docker.sock"
  }

  networks_advanced {
    name    = var.ingress_network_name
    aliases = ["forgejo-runner"]
  }

  depends_on = [
    docker_image.job_node,
  ]
}
