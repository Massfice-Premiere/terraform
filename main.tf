terraform {
  required_providers {
    # github = {
    #   source  = "integrations/github"
    #   version = "~> 5.0"
    # }
    digitaloacen = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

module "digital_ocean_module" {
  source = "./modules/digitalocean_module"

  token = var.digitalocean_token
}

# variable "GITHUB_TOKEN" {
#   type = string
# }

# provider "github" {
#   owner = "massficePremiere"
#   token = var.GITHUB_TOKEN
# }

# resource "github_repository" "repository" {
#   name        = "example-terraform-repository"
#   description = "example-terraform-repository"
#   visibility  = "private"
#   auto_init   = true
# }

# resource "github_repository_file" "create-sealed-secret" {
#   repository     = github_repository.repository.name
#   branch         = "main"
#   file           = ".github/workflows/create-sealed-secret.yaml"
#   content        = file(".github/workflows/create-sealed-secret.yaml")
#   commit_message = "Added sealed secret workflow"

#   provisioner "local-exec" {
#     command = "curl --location --request POST 'https://api.github.com/repos/massficePremiere/${github_repository.repository.name}/dispatches' --header 'Accept: application/vnd.github.everest-preview+json' --header 'Authorization: Bearer ${var.GITHUB_TOKEN}' --header 'Content-Type: application/json' --data-raw '{\"event_type\": \"create-sealed-secret\"}'"
#   }
# }
