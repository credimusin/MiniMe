variable "image_tag" {
  description = "Verified Forgejo rootless image tag (linux/amd64)"
  type        = string
  default     = "17.0.0-rootless"
}

variable "base_domain" {
  description = "Base domain for Forgejo routing"
  type        = string
}

variable "protocol" {
  description = "External protocol (http or https)"
  type        = string
  default     = "http"
}

variable "ssh_port" {
  description = "External SSH port exposed on host for Git over SSH"
  type        = number
  default     = 2222
}

variable "ingress_network_name" {
  description = "Reverse proxy network name"
  type        = string
}

variable "backend_network_name" {
  description = "Internal database network name"
  type        = string
}

variable "data_volume_name" {
  description = "Stateful volume name for /var/lib/gitea"
  type        = string
}

variable "config_volume_name" {
  description = "Stateful volume name for /etc/gitea"
  type        = string
}

variable "db_host" {
  description = "PostgreSQL host on backend network"
  type        = string
}

variable "db_port" {
  description = "PostgreSQL port"
  type        = number
  default     = 5432
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
}

variable "db_user" {
  description = "PostgreSQL user"
  type        = string
}

variable "db_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}
