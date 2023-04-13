terraform {
  required_providers {}
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}

resource "sealedsecret_raw_secrets" "secret" {
  name        = var.name
  namespace   = var.namespace
  certificate = var.sealing_certificate
  values      = var.data
}

data "template_file" "sealed-secret-yaml" {
  template = file("templates/sealed-secret.template.yaml")
  vars = {
    SECRET_NAME = var.name
    SECRET_TYPE = var.type
    SECRET_DATA = sealedsecret_raw_secrets.secret.encrypted_values
  }
}

resource "github_repository_file" "sealed-secret" {
  repository     = var.github_argocd-repo
  branch         = "main"
  file           = var.location
  commit_message = "Terraform > ${var.location}"
  content        = data.template_file.sealed-secret-yaml.rendered
}
