output "container_name" {
  description = "Forgejo container hostname"
  value       = docker_container.forgejo.name
}

output "http_port" {
  description = "Internal HTTP port for reverse proxy upstream"
  value       = local.http_port
}
