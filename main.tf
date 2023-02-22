terraform {
  required_providers {}
}

module "digitalocean_module" {
  source = "./modules/digitalocean_module"

  token = var.digitalocean_token
}

module "kubernetes_module" {
  source = "./modules/kubernetes_module"

  kubernetes_host        = module.digitalocean_module.kubernetes_host
  kubernetes_token       = module.digitalocean_module.kubernetes_token
  kubernetes_certificate = module.digitalocean_module.kubernetes_certificate
  loadbalancer_ip        = module.digitalocean_module.loadbalancer_ip
}

