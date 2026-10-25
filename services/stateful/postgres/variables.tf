variable "image_tag" {
  description = "Verified PostgreSQL image tag (linux/amd64)"
  type        = string
  default     = "17.11-alpine"
}

variable "network_name" {
  description = "Internal backend network name"
  type        = string
}

variable "admin_user" {
  description = "PostgreSQL cluster superuser name"
  type        = string
  default     = "postgres"
}

variable "admin_password" {
  description = "Password for the PostgreSQL cluster superuser"
  type        = string
  sensitive   = true
}

variable "databases" {
  description = "Map of isolated databases (key = database name) and their dedicated owner credentials"
  type = map(object({
    user     = string
    password = string
  }))
  sensitive = true
}
