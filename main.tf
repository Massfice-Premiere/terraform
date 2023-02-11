terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

provider "github" {}

# resource "github_repository" "repository" {
#   name        = "example-terraform-repository"
#   description = "example-terraform-repository"
#   visibility  = "private"
# }
