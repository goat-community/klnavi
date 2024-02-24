variable "hcloud_token" {
  type        = string
  sensitive   = true
  description = "Hetzner Cloud API token"
}

variable "aws_region" {
  type        = string
  default     = "eu-central-1"
  description = "AWS region"
}

variable "aws_access_key" {
  type        = string
  sensitive   = true
  description = "AWS access key"
}

variable "aws_secret_key" {
  type        = string
  sensitive   = true
  description = "AWS secret key"
}

variable "kube_hetzner_ssh_private_key" {
  default = "~/.ssh/klnavi_kube_hetzner"
  description = "Path to the private key to use for SSH access to the Kubernetes cluster."
}

variable "kube_hetzner_ssh_public_key" {
  default = "~/.ssh/klnavi_kube_hetzner.pub"
  description = "Path to the public key to use for SSH access to the Kubernetes cluster."
}
