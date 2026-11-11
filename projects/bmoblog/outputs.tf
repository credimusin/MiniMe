output "container_name" {
  description = "Name of the bmoBlog container"
  value       = docker_container.bmoblog.name
}

output "http_port" {
  description = "Internal HTTP port exposed by bmoBlog"
  value       = local.http_port
}
