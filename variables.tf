variable "digitalocean_token" {
  type        = string
  description = "token for connecting to digitalocean"
}

variable "github_token" {
  type        = string
  description = "token for connecting to github"
}

variable "mongodbatlas_public_key" {
  type        = string
  description = "public key for connecting to mongodb atlas"
}

variable "mongodbatlas_private_key" {
  type        = string
  description = "private key for connecting to mongodb atlas"
}

variable "mongodbatlas_project_id" {
  type        = string
  description = "mongodb atlas project id"
}

variable "identifier_name" {
  type = string
  description = "application or project name"
}

variable "letsencrypt_email" {
  type        = string
  description = "email for ssl certificate"
}

variable "domain" {
  type        = string
  description = "domain which point to cluster loadbalancer"
}

variable "github_owner" {
  type        = string
  description = "owner of github org"
}

variable "github_argo_repo" {
  type        = string
  description = "name of argocd repository"
}

variable "argocd_password" {
  type        = string
  description = "admin password for argocd"
}
