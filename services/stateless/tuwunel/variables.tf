variable "image_tag" {
  description = "Verified Tuwunel Matrix homeserver image tag (linux/amd64)"
  type        = string
  default     = "v1.9.4"
}

variable "base_domain" {
  description = "Base domain for Matrix homeserver routing"
  type        = string
}

variable "subdomain" {
  description = "Subdomain prefix for the Matrix homeserver"
  type        = string
  default     = "quack"
}

variable "ingress_network_name" {
  description = "Reverse proxy network name"
  type        = string
}

variable "data_volume_name" {
  description = "Stateful volume name for /var/lib/tuwunel"
  type        = string
}

variable "registration_token" {
  description = "Secret token required to register new accounts on the Matrix homeserver"
  type        = string
  sensitive   = true
}

variable "max_request_size" {
  description = "Maximum allowed upload size in bytes (default 1 GiB)"
  type        = number
  default     = 1073741824
}

variable "allow_federation" {
  description = "Whether to allow federation with external Matrix servers"
  type        = bool
  default     = false
}
