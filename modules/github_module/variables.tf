variable "token" {
  type        = string
  description = "token for connecting to github"
}

variable "owner" {
  type        = string
  description = "owner of github org"
}

variable "argocd-repo" {
  type        = string
  description = "name of argocd repository"
}

variable "cluster-domain" {
  type        = string
  description = "domain of argocd cluster"
}

variable "secrets" {
  type = object({
    name     = string
    type     = string
    location = string
    data     = map(string)
  })
  description = "map of secrets"
}
