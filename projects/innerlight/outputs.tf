output "container_name" {
  description = "Inner Light container hostname"
  value       = docker_container.innerlight.name
}

output "http_port" {
  description = "Internal HTTP port for reverse proxy upstream"
  value       = local.http_port
}
