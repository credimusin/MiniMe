resource "docker_network" "ingress" {
  name   = "minime_ingress"
  driver = "bridge"

  ipam_options = {
    driver = "host-local"
  }
}

resource "docker_network" "backend" {
  name     = "minime_backend"
  driver   = "bridge"
  internal = true

  ipam_options = {
    driver = "host-local"
  }
}

module "storage" {
  source = "./services/stateful/storage"
}

module "postgres" {
  source = "./services/stateful/postgres"

  network_name   = docker_network.backend.name
  admin_password = var.postgres_admin_password

  databases = {
    forgejo = {
      user     = "forgejo"
      password = var.forgejo_db_password
    }
  }
}

module "forgejo" {
  source = "./services/stateless/forgejo"

  base_domain          = var.base_domain
  protocol             = "https"
  ssh_port             = var.forgejo_ssh_port
  ingress_network_name = docker_network.ingress.name
  backend_network_name = docker_network.backend.name

  data_volume_name   = module.storage.forgejo_data_volume_name
  config_volume_name = module.storage.forgejo_config_volume_name

  db_host     = module.postgres.container_name
  db_port     = module.postgres.port
  db_name     = "forgejo"
  db_user     = "forgejo"
  db_password = var.forgejo_db_password
}

module "runner" {
  source = "./services/stateless/runner"

  forgejo_instance_url = "http://${module.forgejo.container_name}:${module.forgejo.http_port}"
  runner_token         = var.forgejo_runner_token
  ingress_network_name = docker_network.ingress.name
  data_volume_name     = module.storage.runner_data_volume_name
}

module "tuwunel" {
  source = "./services/stateless/tuwunel"

  base_domain          = var.base_domain
  ingress_network_name = docker_network.ingress.name
  data_volume_name     = module.storage.tuwunel_data_volume_name
  registration_token   = var.tuwunel_registration_token
}

module "caddy" {
  source = "./services/stateless/caddy"

  base_domain          = var.base_domain
  tls_internal         = var.tls_internal
  ingress_network_name = docker_network.ingress.name

  data_volume_name   = module.storage.caddy_data_volume_name
  config_volume_name = module.storage.caddy_config_volume_name

  forgejo_upstream      = "${module.forgejo.container_name}:${module.forgejo.http_port}"
  innerlight_upstream   = "${module.innerlight.container_name}:${module.innerlight.http_port}"
  imaginaldev_upstream  = "${module.imaginaldev.container_name}:${module.imaginaldev.http_port}"
  minimestatus_upstream = "${module.minimestatus.container_name}:${module.minimestatus.http_port}"
  tuwunel_upstream      = "${module.tuwunel.container_name}:${module.tuwunel.http_port}"
  quackindex_upstream   = "${module.quackindex.container_name}:${module.quackindex.http_port}"
}

module "frpc" {
  source = "./services/stateless/frpc"

  vps_addr             = var.frp_vps_addr
  auth_token           = var.frp_auth_token
  ingress_network_name = docker_network.ingress.name
  caddy_host           = module.caddy.container_name
  forgejo_host         = module.forgejo.container_name
  ssh_port             = var.forgejo_ssh_port
}

module "innerlight" {
  source = "./projects/innerlight"

  ingress_network_name = docker_network.ingress.name
  source_dir           = var.innerlight_source_dir
}

module "imaginaldev" {
  source = "./projects/imaginaldev"

  ingress_network_name = docker_network.ingress.name
  source_dir           = var.imaginaldev_source_dir
}

module "minimestatus" {
  source = "./projects/minimestatus"

  ingress_network_name = docker_network.ingress.name
  source_dir           = var.minimestatus_source_dir
}

module "quackbot" {
  source = "./projects/quackbot"

  source_dir           = var.quackbot_source_dir
  image_id             = module.runner.job_image_id
  homeserver_url       = "http://${module.tuwunel.container_name}:${module.tuwunel.http_port}"
  server_name          = module.tuwunel.fqdn
  admin_username       = var.tuwunel_admin_username
  registration_token   = var.tuwunel_registration_token
  ingress_network_name = docker_network.ingress.name
}

module "quackindex" {
  source = "./projects/quackindex"

  ingress_network_name = docker_network.ingress.name
  source_dir           = var.quackindex_source_dir
}
