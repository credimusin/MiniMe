resource "docker_network" "ingress" {
  name   = "minime_ingress"
  driver = "bridge"
}

resource "docker_network" "backend" {
  name     = "minime_backend"
  driver   = "bridge"
  internal = true
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
  protocol             = var.tls_internal ? "http" : "https"
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

module "caddy" {
  source = "./services/stateless/caddy"

  base_domain          = var.base_domain
  tls_internal         = var.tls_internal
  ingress_network_name = docker_network.ingress.name

  data_volume_name   = module.storage.caddy_data_volume_name
  config_volume_name = module.storage.caddy_config_volume_name

  forgejo_upstream = "${module.forgejo.container_name}:${module.forgejo.http_port}"
}

# ==============================================================================
# 3. PROJECTS (Custom pet-projects consuming stateful & stateless services)
# ==============================================================================
# Add custom project modules from ./projects/<name> here.
