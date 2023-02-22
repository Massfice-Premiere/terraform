terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

module "digital_ocean_module" {
  source = "./modules/digitalocean_module"

  token = var.digitalocean_token
}

provider "github" {
  owner = "massficePremiere"
  token = var.GITHUB_TOKEN
}

