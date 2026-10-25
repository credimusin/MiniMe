variable "image_tag" {
  description = "Verified Forgejo Runner image tag (linux/amd64)"
  type        = string
  default     = "13.2.0"
}

variable "job_image" {
  description = "Default container image for ubuntu-latest CI jobs (includes Node 24, git, curl, unzip)"
  type        = string
  default     = "docker.io/library/node:24-bookworm"
}

variable "forgejo_instance_url" {
  description = "Internal URL of the Forgejo instance"
  type        = string
}

variable "runner_token" {
  description = "Registration token from Forgejo Actions"
  type        = string
  sensitive   = true
}

variable "ingress_network_name" {
  description = "Docker network shared with Forgejo and Caddy"
  type        = string
}

variable "data_volume_name" {
  description = "Stateful volume name for runner registration state (/data)"
  type        = string
}

variable "podman_socket_path" {
  description = "Host path to Rootless Podman socket on monster"
  type        = string
  default     = "/run/user/1000/podman/podman.sock"
}
