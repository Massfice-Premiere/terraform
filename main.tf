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

resource "tls_private_key" "sealed-secret-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "sealed-secret-cert" {
  private_key_pem       = tls_private_key.sealed-secret-key.private_key_pem
  validity_period_hours = 87660
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  subject {
    common_name  = "sealed_secrets"
    organization = "sealed_secrets"
  }
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

module "secret_module" {
  source = "./modules/secret_module"

  for_each = {
    example_secret = {
      name      = "example-secret"
      namespace = "example"
      type      = "Opaque"
      location  = "apps/standard/example/example-secret.yaml"
      data = {
        EXAMPLE_VALUE = "example value"
      }
    }
    example_secret_2 = {
      name      = "example-secret"
      namespace = "example2"
      type      = "Opaque"
      location  = "apps/standard/example2/example-secret.yaml"
      data = {
        EXAMPLE_VALUE = "example value"
      }
    }
  }

  name                = each.value.name
  namespace           = each.value.namespace
  type                = each.value.type
  location            = each.value.location
  data                = each.value.data
  sealing_certificate = tls_self_signed_cert.sealed-secret-cert.cert_pem

  providers = {
    github       = github.github
    sealedsecret = sealedsecret.sealedsecret
  }
}

module "github_module" {
  source = "./modules/github_module"

  token          = var.github_token
  owner          = var.github_owner
  argocd-repo    = var.github_argo_repo
  cluster-domain = var.domain
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
}
