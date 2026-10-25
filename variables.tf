variable "docker_host" {
  description = "Podman API socket URI over SSH (uses host alias from ~/.ssh/config)"
  type        = string
  default     = "ssh://monster/run/user/1000/podman/podman.sock"
}

variable "base_domain" {
  description = "Base domain for homelab services (override in terraform.tfvars)"
  type        = string
  default     = "homelab.internal"
}

variable "tls_internal" {
  description = "Use Caddy internal PKI for local LAN before a public IP is attached"
  type        = bool
  default     = true
}

variable "postgres_admin_password" {
  description = "Superuser password for PostgreSQL cluster administration"
  type        = string
  sensitive   = true
}

variable "forgejo_db_password" {
  description = "Isolated PostgreSQL password for the forgejo user and database"
  type        = string
  sensitive   = true
}

variable "forgejo_ssh_port" {
  description = "External port on host for Forgejo Git SSH access"
  type        = number
  default     = 2222
}
