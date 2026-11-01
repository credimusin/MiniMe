output "container_name" {
  description = "MiniMeStatus container hostname"
  value       = docker_container.minimestatus.name
}

output "http_port" {
  description = "Internal HTTP port for reverse proxy upstream"
  value       = local.http_port
}
