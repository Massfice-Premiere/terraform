terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

locals {
  ingress_yaml = templatefile("./templates/ingress.template.yaml", {
    NAME         = var.name
    DOMAIN       = var.domain
    SUB          = var.sub
    SERVICE_NAME = var.service_name
    SERVICE_PORT = var.service_port
  })
}

resource "github_repository_file" "ingress" {
  repository     = var.github_argocd-repo
  branch         = "main"
  file           = var.location
  commit_message = "Terraform > ${var.location}"
  content        = local.ingress_yaml
}
