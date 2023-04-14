terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

data "github_repository_file" "ingress-template-yaml" {
  repository = var.github_argocd-repo
  file       = "templates/ingress.template.yaml"
  branch     = "main"
}

data "template_file" "ingress-yaml" {
  template = data.github_repository_file.ingress-template-yaml.content
  vars = {
    INGRESS_NAME         = var.name
    INGRESS_DOMAIN       = var.domain
    INGRESS_SUB          = var.sub
    INGRESS_SERVICE_NAME = var.service_name
    INGRESS_SERVICE_PORT = tostring(var.service_port)
  }
}

resource "github_repository_file" "ingress" {
  repository     = var.github_argocd-repo
  branch         = "main"
  file           = var.location
  commit_message = "Terraform > ${var.location}"
  content        = data.template_file.ingress-yaml.rendered
}
