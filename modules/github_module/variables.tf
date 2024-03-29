variable "owner" {
  type        = string
  description = "owner of argo cd repo"
}

variable "argocd-repo" {
  type        = string
  description = "name of argocd repository"
}

variable "cluster-domain" {
  type        = string
  description = "domain of argocd cluster"
}
