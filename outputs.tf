output "minime_url" {
  description = "Public homelab showcase and status URL for MiniMe"
  value       = "https://minime.${var.base_domain}"
}

output "imaginal_url" {
  description = "Primary personal portfolio URL"
  value       = "https://${var.base_domain}"
}

output "forgejo_url" {
  description = "Primary web URL for Forgejo"
  value       = "https://forgejo.${var.base_domain}"
}

output "innerlight_url" {
  description = "Primary web URL for Inner Light landing"
  value       = "https://innerlight.${var.base_domain}"
}

output "quack_matrix_url" {
  description = "Matrix homeserver URL for Quack (Tuwunel)"
  value       = "https://${module.tuwunel.fqdn}"
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
    runner_data    = module.storage.runner_data_volume_name
    caddy_data     = module.storage.caddy_data_volume_name
    caddy_config   = module.storage.caddy_config_volume_name
    tuwunel_data   = module.storage.tuwunel_data_volume_name
  }
}
