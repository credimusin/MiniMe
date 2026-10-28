variable "image_tag" {
  description = "Verified Caddy image tag (linux/amd64)"
  type        = string
  default     = "2.11.7-alpine"
}

variable "base_domain" {
  description = "Base domain for reverse proxy routing"
  type        = string
}

variable "tls_internal" {
  description = "Whether to use Caddy internal CA and allow plain HTTP on local LAN"
  type        = bool
  default     = true
}

variable "ingress_network_name" {
  description = "Ingress bridge network name"
  type        = string
}

variable "data_volume_name" {
  description = "Stateful volume name for Caddy /data"
  type        = string
}

variable "config_volume_name" {
  description = "Stateful volume name for Caddy /config"
  type        = string
}

variable "forgejo_upstream" {
  description = "Upstream address (host:port) for Forgejo"
  type        = string
}

variable "innerlight_upstream" {
  description = "Upstream address (host:port) for Inner Light landing"
  type        = string
}
