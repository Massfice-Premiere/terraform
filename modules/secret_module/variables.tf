variable "github_token" {
  type        = string
  description = "token for connecting to github"
}

variable "github_owner" {
  type        = string
  description = "owner of github org"
}

variable "github_argocd-repo" {
  type        = string
  description = "name of argocd repository"
}

variable "name" {
  type        = string
  description = "name of secret"
}

variable "namespace" {
  type        = string
  description = "namespace of secret"
}

variable "type" {
  type        = string
  description = "type of secret"
}

variable "location" {
  type        = string
  description = "location where to store generated sealed secret"
}

variable "data" {
  type        = map(any)
  description = "data of secred"
}

variable "sealing_certificate" {
  type        = string
  description = "certificate to seal secret"
}
