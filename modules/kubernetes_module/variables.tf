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

variable "github_repo_owner" {
  type        = string
  description = "org name"
}

variable "github_argocd_repo" {
  type        = string
  description = "argocd repo name"
}

variable "domain" {
  type        = string
  description = "domain of cluster"
}

variable "argocd_password" {
  type        = string
  description = "admin password for argocd"
}


variable "init-yaml" {
  type        = string
  description = "rendered init.yaml"
}

variable "projects-yaml" {
  type        = string
  description = "projects.yaml"
}

variable "application-set-yaml" {
  type        = string
  description = "application-set.yaml"
}

variable "sealed-secret-cert" {
  type        = string
  description = "encryption certificate for sealed secrets"
}

variable "sealed-secret-key" {
  type        = string
  description = "decryption key for sealead secrets"
}

variable "dockerhub_username" {
  type        = string
  description = "dockehub username"
}

variable "dockerhub_password" {
  type        = string
  description = "dockerhub password"
}
