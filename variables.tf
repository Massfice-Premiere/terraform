variable "digitalocean_token" {
  type        = string
  description = "token for connecting to digitalocean"
}

variable "github_token" {
  type        = string
  description = "token for connecting to github"
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
