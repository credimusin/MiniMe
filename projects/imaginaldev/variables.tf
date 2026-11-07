variable "image_tag" {
  description = "Verified Node.js Alpine image tag (linux/amd64)"
  type        = string
  default     = "24-alpine"
}

variable "ingress_network_name" {
  description = "Ingress bridge network name shared with Caddy"
  type        = string
}

variable "source_dir" {
  description = "Local path to the ImaginalDev portfolio repository"
  type        = string
  default     = "/var/home/bmo/Devs/ImaginalDev"
}
