output "forgejo_data_volume_name" {
  description = "Volume storing Forgejo repositories and LFS/attachment data"
  value       = docker_volume.forgejo_data.name
}

output "forgejo_config_volume_name" {
  description = "Volume storing Forgejo app.ini configuration"
  value       = docker_volume.forgejo_config.name
}

output "runner_data_volume_name" {
  description = "Volume storing Forgejo Actions runner registration state"
  value       = docker_volume.runner_data.name
}

output "caddy_data_volume_name" {
  description = "Volume storing Caddy PKI / ACME certificates"
  value       = docker_volume.caddy_data.name
}

output "caddy_config_volume_name" {
  description = "Volume storing Caddy runtime state"
  value       = docker_volume.caddy_config.name
}
