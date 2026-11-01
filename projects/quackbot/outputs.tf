output "container_name" {
  description = "QuackBot container name"
  value       = docker_container.quackbot.name
}

output "room_alias" {
  description = "Public Matrix channel alias for HackerNews"
  value       = "#hackernews:${var.server_name}"
}
