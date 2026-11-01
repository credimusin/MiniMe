output "container_name" {
  description = "QuackIndex container hostname"
  value       = docker_container.quackindex.name
}

output "http_port" {
  description = "Internal HTTP port for reverse proxy upstream"
  value       = local.http_port
}
