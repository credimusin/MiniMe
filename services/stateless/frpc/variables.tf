variable "image_tag" {
  description = "Verified frpc image tag (linux/amd64)"
  type        = string
  default     = "v0.71.1"
}

variable "vps_addr" {
  description = "Public IP or hostname of the VPS running frps"
  type        = string
}

variable "vps_port" {
  description = "Control port of frps on the VPS"
  type        = number
  default     = 7000
}

variable "auth_token" {
  description = "Shared secret token matching frps.toml"
  type        = string
  sensitive   = true
}

variable "ingress_network_name" {
  description = "Ingress bridge network shared with Caddy and Forgejo"
  type        = string
}

variable "caddy_host" {
  description = "Caddy container hostname on ingress network"
  type        = string
  default     = "minime-caddy"
}

variable "forgejo_host" {
  description = "Forgejo container hostname on ingress network"
  type        = string
  default     = "minime-forgejo"
}

variable "ssh_port" {
  description = "External Git SSH port"
  type        = number
  default     = 2222
}
