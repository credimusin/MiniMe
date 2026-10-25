output "container_name" {
  description = "Forgejo Actions runner container name"
  value       = docker_container.runner.name
}
