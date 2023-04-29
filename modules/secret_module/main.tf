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

resource "sealedsecret_raw_secrets" "secret-data" {
  name        = var.name
  namespace   = var.namespace
  certificate = var.sealing_certificate
  values      = var.data
}

locals {
  sealed_secret_yaml = templatefile("./templates/sealed-secret.template.yaml", {
    NAME = var.name
    TYPE = var.type
    DATA = sealedsecret_raw_secrets.secret-data.encrypted_values
  })
}

resource "github_repository_file" "sealed-secret" {
  repository     = var.github_argocd-repo
  branch         = "main"
  file           = var.location
  commit_message = "Terraform > ${var.location}"
  content        = local.sealed_secret_yaml
}
