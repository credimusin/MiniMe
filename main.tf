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

# ==============================================================================
# 1. SERVICES: STATEFUL (Protected persistent volumes & multi-tenant databases)
# ==============================================================================

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

# ==============================================================================
# 2. SERVICES: STATELESS (Replaceable infrastructure & self-hosted apps)
# ==============================================================================

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

module "caddy" {
  source = "./services/stateless/caddy"

  base_domain          = var.base_domain
  tls_internal         = var.tls_internal
  ingress_network_name = docker_network.ingress.name

  data_volume_name   = module.storage.caddy_data_volume_name
  config_volume_name = module.storage.caddy_config_volume_name

  forgejo_upstream    = "${module.forgejo.container_name}:${module.forgejo.http_port}"
  innerlight_upstream = "${module.innerlight.container_name}:${module.innerlight.http_port}"
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

# ==============================================================================
# 3. PROJECTS (Custom pet-projects consuming stateful & stateless services)
# ==============================================================================

module "innerlight" {
  source = "./projects/innerlight"

  ingress_network_name = docker_network.ingress.name
  source_dir           = var.innerlight_source_dir
}
