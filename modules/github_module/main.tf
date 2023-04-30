terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
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

locals {
  init_yaml = templatefile("./templates/init.template.yaml", {
    REPO_URL = "git@github.com:${var.owner}/${var.argocd-repo}.git"
  })

  application_set_yaml = templatefile("./templates/application-set.template.yaml", {
    REPO_URL = "git@github.com:${var.owner}/${var.argocd-repo}.git"
  })

  projects_yaml = templatefile("./templates/projects.template.yaml", {
    REPO_URL = "git@github.com:${var.owner}/${var.argocd-repo}.git"
  })
}

resource "github_repository_file" "init-yaml" {
  repository     = var.argocd-repo
  branch         = "main"
  file           = "apps/init/init.yaml"
  commit_message = "Terraform > init.yaml"
  content        = local.init_yaml
}

resource "github_repository_file" "projects-yaml" {
  repository     = var.argocd-repo
  branch         = "main"
  file           = "apps/init/projects.yaml"
  commit_message = "Terraform > projects.yaml"
  content        = local.projects_yaml
}

# resource "github_repository_file" "application-set-yaml" {
#   repository     = var.argocd-repo
#   branch         = "main"
#   file           = "apps/init/application-set.yaml"
#   commit_message = "Terraform > projects.yaml"
#   content        = local.application_set_yaml
# }
