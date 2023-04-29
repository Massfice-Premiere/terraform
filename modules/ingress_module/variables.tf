variable "github_argocd-repo" {
  type        = string
  description = "name of argocd repository"
}

variable "name" {
  type        = string
  description = "name of ingress"
}

variable "service_name" {
  type        = string
  description = "service name"
}

variable "service_port" {
  type        = number
  description = "service port number"
}

variable "domain" {
  type        = string
  description = "domain"
}

variable "sub" {
  type        = string
  description = "subdomain"
}

variable "location" {
  type        = string
  description = "location where to store generated ingress configuration"
}
