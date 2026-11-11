output "container_name" {
  description = "ImaginalDev container hostname"
  value       = docker_container.landing.name
}

output "http_port" {
  description = "Internal HTTP port for reverse proxy upstream"
  value       = local.http_port
}
