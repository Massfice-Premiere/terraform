terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    sealedsecret = {
      source = "2ttech/sealedsecret"
    }
  }
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
  alias = "github"
}

provider "sealedsecret" {
  alias = "sealedsecret"
}

module "digitalocean_module" {
  source = "./modules/digitalocean_module"

  token        = var.digitalocean_token
  domain       = var.domain
  cluster_name = var.identifier_name
}

module "mongodbatlas_module" {
  source = "./modules/mongodbatlas_module"

  public_key  = var.mongodbatlas_public_key
  private_key = var.mongodbatlas_private_key
  project_id  = var.mongodbatlas_project_id
  db_name     = var.identifier_name
  ips_to_whitelist = {
    kubernetes_node0 = module.digitalocean_module.node0_ip,
    kubernetes_node1 = module.digitalocean_module.node1_ip,
    kubernetes_node2 = module.digitalocean_module.node2_ip
  }
}

module "github_module" {
  source = "./modules/github_module"

  argocd-repo    = var.github_argo_repo
  cluster-domain = var.domain
  owner          = var.github_owner

  providers = {
    github = github.github
  }
}

module "kubernetes_module" {
  source = "./modules/kubernetes_module"

  kubernetes_host        = module.digitalocean_module.kubernetes_host
  kubernetes_token       = module.digitalocean_module.kubernetes_config[0].token
  kubernetes_certificate = module.digitalocean_module.kubernetes_config[0].cluster_ca_certificate
  loadbalancer_id        = module.digitalocean_module.loadbalancer_id
  loadbalancer_name      = module.digitalocean_module.loadbalancer_name
  github_private_key     = module.github_module.private_key
  init-yaml              = module.github_module.init-yaml
  projects-yaml          = module.github_module.projects-yaml
  github_repo_owner      = var.github_owner
  github_argocd_repo     = var.github_argo_repo
  letsencrypt_email      = var.letsencrypt_email
  domain                 = var.domain
  argocd_password        = var.argocd_password
  sealed-secret-cert     = tls_self_signed_cert.sealed-secret-cert.cert_pem
  sealed-secret-key      = tls_self_signed_cert.sealed-secret-cert.private_key_pem
}
