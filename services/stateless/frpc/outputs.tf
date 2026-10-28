output "container_name" {
  description = "FRP client container name"
  value       = docker_container.frpc.name
}
