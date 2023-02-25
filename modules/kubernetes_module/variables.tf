variable "kubernetes_host" {
  type        = string
  description = "kubernetes host"
}

variable "kubernetes_token" {
  type        = string
  description = "kubernetes token"
}

variable "kubernetes_certificate" {
  type        = string
  description = "kubernetes certificate"
}

variable "loadbalancer_id" {
  type        = string
  description = "loadbalancer id"
}

variable "loadbalancer_name" {
  type        = string
  description = "loadbalancer name"
}

variable "letsencrypt_email" {
  type        = string
  description = "email for ssl certificate"
}

variable "github_private_key" {
  type        = string
  description = "private key in openssh format for connecting argocd to github repository"
}
