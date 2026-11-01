output "container_name" {
  description = "Forgejo Actions runner container name"
  value       = docker_container.runner.name
}

output "job_image_id" {
  description = "Shared Node.js image ID for lightweight scripts and CI jobs"
  value       = docker_image.job_node.image_id
}
