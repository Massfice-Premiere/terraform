terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    sealedsecret = {
      source = "2ttech/sealedsecret"
    }
  }
}

data "github_repository_file" "sealed-secret-template-yaml" {
  repository = var.github_argocd-repo
  file       = "templates/sealed-secret.template.yaml"
  branch     = "main"
}

resource "sealedsecret_raw_secrets" "secret-data" {
  name        = var.name
  namespace   = var.namespace
  certificate = var.sealing_certificate
  values      = var.data
}

data "template_file" "sealed-secret-yaml" {
  template = data.github_repository_file.sealed-secret-template-yaml.content
  vars = {
    SECRET_NAME = var.name
    SECRET_TYPE = var.type
    SECRET_DATA = trimspace(yamlencode({ for k, v in sealedsecret_raw_secrets.secret-data.encrypted_values : "    ${k}" => v }))
  }
}

resource "github_repository_file" "sealed-secret" {
  repository     = var.github_argocd-repo
  branch         = "main"
  file           = var.location
  commit_message = "Terraform > ${var.location}"
  content        = data.template_file.sealed-secret-yaml.rendered
}
