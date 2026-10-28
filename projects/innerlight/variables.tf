variable "image_tag" {
  description = "Verified nginx Alpine image tag (linux/amd64)"
  type        = string
  default     = "1.30.6-alpine"
}

variable "ingress_network_name" {
  description = "Ingress bridge network name shared with Caddy"
  type        = string
}

variable "source_dir" {
  description = "Local path to the inner-light-landing repository"
  type        = string
  default     = "/var/home/bmo/Devs/inner-light-landing"
}
