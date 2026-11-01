variable "image_id" {
  description = "Shared Node.js image ID (reuses runner job image for zero extra disk footprint)"
  type        = string
}

variable "source_dir" {
  description = "Local path to the QuackBot repository"
  type        = string
  default     = "/var/home/bmo/Devs/QuackBot"
}

variable "homeserver_url" {
  description = "Internal HTTP URL of the Tuwunel Matrix homeserver"
  type        = string
}

variable "server_name" {
  description = "Matrix homeserver domain name"
  type        = string
}

variable "admin_username" {
  description = "Primary user to auto-invite and grant room administration"
  type        = string
  sensitive   = true
}

variable "registration_token" {
  description = "Tuwunel registration token used for initial bot account bootstrap"
  type        = string
  sensitive   = true
}

variable "min_score" {
  description = "Minimum HackerNews points threshold to post a story"
  type        = number
  default     = 100
}

variable "ingress_network_name" {
  description = "Docker network shared with Tuwunel"
  type        = string
}
