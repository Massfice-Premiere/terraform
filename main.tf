terraform {
  required_providers {}
}

module "digitalocean_module" {
  source = "./modules/digitalocean_module"

  token = var.digitalocean_token
}


# module "kubernetes_module" {
#   source = "./modules/kubernetes_module"

#   kubernetes_host        = module.digital_ocean_module.kubernetes_host
#   kubernetes_token       = module.digital_ocean_module.kubernetes_token
#   kubernetes_certificate = module.digital_ocean_module.kubernetes_certificate
#   loadbalancer_ip        = module.digital_ocean_module.loadbalancer_ip
# }

