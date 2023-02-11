terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

provider "github" {
  owner = "massficePremiere"
}

resource "github_repository" "repository" {
  name        = "example-terraform-repository"
  description = "example-terraform-repository"
  visibility  = "private"
  auto_init   = true
}

resource "github_repository_file" "create-sealed-secret" {
  depends_on = [
    github_repository.repository
  ]

  repository     = github_repository.repository.name
  branch         = "main"
  file           = "./.github/workflows/create-sealed-secret.yaml"
  content        = file("./.github/workflows/create-sealed-secret.yaml")
  commit_message = "Added sealed secret workflow"
}
