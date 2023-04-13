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
  type = map(
    object({
      name      = string
      namespace = string
      type      = string
      location  = string
      data      = map(any)
    })
  )
  description = "map of secrets"
}

variable "sealed-secrets-key" {
  type        = string
  description = "key for sealing secrets"
}
