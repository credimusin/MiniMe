output "forgejo_url" {
  description = "Primary web URL for Forgejo"
  value       = "https://forgejo.${var.base_domain}"
}

output "forgejo_ssh_clone_base" {
  description = "Base SSH URL for cloning repositories from Forgejo"
  value       = "ssh://git@forgejo.${var.base_domain}:${var.forgejo_ssh_port}"
}

output "stateful_volumes" {
  description = "Protected persistent volumes managed in the stateful layer"
  value = {
    postgres_data  = module.postgres.volume_name
    forgejo_data   = module.storage.forgejo_data_volume_name
    forgejo_config = module.storage.forgejo_config_volume_name
    caddy_data     = module.storage.caddy_data_volume_name
    caddy_config   = module.storage.caddy_config_volume_name
  }
}
