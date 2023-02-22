terraform {
  required_providers {}
}

module "digital_ocean_module" {
  source = "./modules/digitalocean_module"

  token = var.digitalocean_token
}

