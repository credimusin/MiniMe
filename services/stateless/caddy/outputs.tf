output "container_name" {
  description = "Caddy reverse proxy container name"
  value       = docker_container.caddy.name
}
