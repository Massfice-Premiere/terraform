terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    sealed-secrets = {
      source = "datalbry/sealed-secrets"
    }
  }
}

provider "github" {
  token = var.token
  owner = var.owner
}

resource "tls_private_key" "sealed-secret-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


provider "sealed-secrets" {
  pem = tls_private_key.sealed-secret-key.public_key_openssh
}

resource "tls_private_key" "tls-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "github_user_ssh_key" "argocd-key" {
  title = "argocd-key"
  key   = tls_private_key.tls-key.public_key_openssh
}

resource "github_repository_webhook" "argocd-webhook" {
  repository = var.argocd-repo
  events     = ["push"]
  configuration {
    url          = "https://argocd.${var.cluster-domain}/api/webhook"
    content_type = "json"
  }
}

data "github_repository_file" "init-template-yaml" {
  repository = var.argocd-repo
  file       = "templates/init.template.yaml"
  branch     = "main"
}

data "github_repository_file" "projects-template-yaml" {
  repository = var.argocd-repo
  file       = "templates/projects.template.yaml"
  branch     = "main"
}

data "template_file" "init-yaml" {
  template = data.github_repository_file.init-template-yaml.content
  vars = {
    REPO_URL = "git@github.com:${var.owner}/${var.argocd-repo}.git"
  }
}

data "template_file" "projects-yaml" {
  template = data.github_repository_file.projects-template-yaml.content
  vars = {
    REPO_URL = "git@github.com:${var.owner}/${var.argocd-repo}.git"
  }
}

resource "github_repository_file" "init-yaml" {
  repository     = var.argocd-repo
  branch         = "main"
  file           = "apps/init/init.yaml"
  commit_message = "Terraform > init.yaml"
  content        = data.template_file.init-yaml.rendered
}

resource "github_repository_file" "projects-yaml" {
  repository     = var.argocd-repo
  branch         = "main"
  file           = "apps/init/projects.yaml"
  commit_message = "Terraform > projects.yaml"
  content        = data.template_file.projects-yaml.rendered
}

data "selead-secrets_sealed_secret" "secrets" {
  for_each    = var.secrets
  name        = each.value.name
  namespace   = each.value.namespace
  secret_type = each.value.type
  data        = each.value.data
}
