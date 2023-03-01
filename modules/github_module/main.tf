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

resource "local_file" "init-template-yaml" {
  filename = "init.template.yaml"
  content  = data.github_repository_file.init-template-yaml.content
}

resource "github_repository_file" "name" {
  repository     = var.argocd-repo
  branch         = "main"
  file           = "test/init.yaml"
  commit_message = "Terraform > init.yaml"
  content        = templatefile("init.template.yaml", { REPO_URL = "git@github.com:${var.owner}/${var.argocd-repo}.git" })

  depends_on = [
    local_file.init-template-yaml
  ]
}
