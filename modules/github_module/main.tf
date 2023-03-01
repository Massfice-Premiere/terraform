terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

provider "github" {
  token = var.token
  owner = var.owner
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

data "template_file" "init-yaml" {
  template = data.github_repository_file.init-template-yaml.content
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
