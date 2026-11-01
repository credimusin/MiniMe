output "container_name" {
  description = "Tuwunel Matrix container hostname"
  value       = docker_container.tuwunel.name
}

output "http_port" {
  description = "Internal HTTP port for reverse proxy upstream"
  value       = local.http_port
}

output "fqdn" {
  description = "Full Matrix homeserver domain name"
  value       = local.fqdn
}
