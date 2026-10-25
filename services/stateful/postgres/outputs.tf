output "container_name" {
  description = "PostgreSQL container hostname on the backend network"
  value       = docker_container.postgres.name
}

output "port" {
  description = "Internal PostgreSQL port"
  value       = 5432
}

output "volume_name" {
  description = "Protected PostgreSQL data volume name"
  value       = docker_volume.postgres_data.name
}

output "provisioned_databases" {
  description = "List of isolated database names managed by PostgreSQL"
  value       = keys(nonsensitive(var.databases))
}
