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

resource "github_repository_file" "chart-yaml" {
  repository     = var.argocd-repo
  branch         = "main"
  file           = "apps/argocd/Chart.yaml"
  content        = file("../../charts/argocd-application/Chart.yaml")
  commit_message = "Argo CD Application | Chart.yaml | Managed by Terraform"
}

resource "github_repository_file" "application-yaml" {
  repository     = var.argocd-repo
  branch         = "main"
  file           = "apps/argocd/templates/application.yaml"
  content        = file("../../charts/argocd-application/templates/application.yaml")
  commit_message = "Argo CD Application | application.yaml | Managed by Terraform"
}

resource "github_repository_file" "values-yaml" {
  repository     = var.argocd-repo
  branch         = "main"
  file           = "apps/argocd/templates/values.yaml"
  content        = "repo_url: git@github.com:${var.owner}/${var.argocd-repo}.git\n"
  commit_message = "Argo CD Application | values.yaml | Managed by Terraform"
}
