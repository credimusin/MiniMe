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
  default     = false
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

variable "forgejo_runner_token" {
  description = "Registration token for the Forgejo Actions runner"
  type        = string
  sensitive   = true
}

variable "forgejo_ssh_port" {
  description = "External port on host for Forgejo Git SSH access"
  type        = number
  default     = 2222
}

variable "frp_vps_addr" {
  description = "Public IP or hostname of the VPS running frps"
  type        = string
}

variable "frp_auth_token" {
  description = "Shared authentication token for the FRP tunnel"
  type        = string
  sensitive   = true
}

variable "innerlight_source_dir" {
  description = "Local filesystem path to the inner-light-landing repository"
  type        = string
  default     = "/var/home/bmo/Devs/inner-light-landing"
}
