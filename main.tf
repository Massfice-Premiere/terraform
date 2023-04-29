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

module "ingress_module" {
  source = "./modules/subdomain_module"

  for_each = {
    example_subdomain = {
      name         = "ingress"
      service_name = "todo-example"
      service_port = 80
      sub          = "example"
      location     = "apps/standard/example/ingress.yaml"
    }
    example_subdomain_2 = {
      name         = "ingress"
      service_name = "todo-example"
      service_port = 80
      sub          = "exampletwo"
      location     = "apps/standard/example2/ingress.yaml"
    }
  }

  name               = each.value.name
  service_name       = each.value.service_name
  service_port       = each.value.service_port
  sub                = each.value.sub
  location           = each.value.location
  github_argocd-repo = var.github_argo_repo
  domain             = var.domain

  providers = {
    github = github.github
  }
}

module "secret_module" {
  source = "./modules/secret_module"

  for_each = {
    database_prod_connection_for_example_namespace = {
      name      = "database-connection-secret"
      namespace = "example"
      type      = "Opaque"
      location  = "apps/standard/example/database-connection-secret.yaml"
      data = {
        MONGO_URI      = replace(module.mongodbatlas_module.prod-connection-string, "mongodb+srv://", "mongodb+srv://${module.mongodbatlas_module.prod-user-username}:${urlencode(module.mongodbatlas_module.prod-user-password)}@")
        MONGO_HOST     = module.mongodbatlas_module.prod-connection-string
        MONGO_USERNAME = module.mongodbatlas_module.prod-user-username
        MONGO_PASSWORD = urlencode(module.mongodbatlas_module.prod-user-password)
      }
    }
    database_nonprod_connection_for_example2_namespace = {
      name      = "database-connection-secret"
      namespace = "example2"
      type      = "Opaque"
      location  = "apps/standard/example2/database-connection-secret.yaml"
      data = {
        MONGO_URI      = replace(module.mongodbatlas_module.nonprod-connection-string, "mongodb+srv://", "mongodb+srv://${module.mongodbatlas_module.nonprod-user-username}:${urlencode(module.mongodbatlas_module.nonprod-user-password)}@")
        MONGO_HOST     = module.mongodbatlas_module.nonprod-connection-string
        MONGO_USERNAME = module.mongodbatlas_module.nonprod-user-username
        MONGO_PASSWORD = urlencode(module.mongodbatlas_module.nonprod-user-password)
      }
    }
    pull_secret_for_example_namespace = {
      name      = "pull-secret"
      namespace = "example"
      type      = "kubernetes.io/dockerconfigjson"
      location  = "apps/standard/example/pull-secret.yaml"
      data = {
        ".dockerconfigjson" = jsonencode({
          auths = {
            "https://index.docker.io/v1/" = {
              auth = base64encode("${var.dockerhub_username}:${var.dockerhub_password}")
            }
          }
        })
      }
    }
    pull_secret_for_example2_namespace = {
      name      = "pull-secret"
      namespace = "example2"
      type      = "kubernetes.io/dockerconfigjson"
      location  = "apps/standard/example2/pull-secret.yaml"
      data = {
        ".dockerconfigjson" = jsonencode({
          auths = {
            "https://index.docker.io/v1/" = {
              auth = base64encode("${var.dockerhub_username}:${var.dockerhub_password}")
            }
          }
        })
      }
    }
  }

  name                = each.value.name
  namespace           = each.value.namespace
  type                = each.value.type
  location            = each.value.location
  data                = each.value.data
  sealing_certificate = tls_self_signed_cert.sealed-secret-cert.cert_pem
  github_argocd-repo  = var.github_argo_repo

  providers = {
    github       = github.github
    sealedsecret = sealedsecret.sealedsecret
  }
}
