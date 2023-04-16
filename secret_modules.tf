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

module "secret_module" {
  source = "./modules/secret_module"

  for_each = {
    database_prod_connection_for_example_namespace = {
      name      = "database-connection-secret"
      namespace = "example"
      type      = "Opaque"
      location  = "apps/standard/example/database-connection-secret.yaml"
      data = {
        MONGO_URI = replace(module.mongodbatlas_module.prod-connection-string, "mongodb+srv://", "mongodb+srv://${module.mongodbatlas_module.prod-user-username}:${urlencode(module.mongodbatlas_module.prod-user-password)}@")
      }
    }
    database_nonprod_connection_for_example2_namespace = {
      name      = "database-connection-secret"
      namespace = "example2"
      type      = "Opaque"
      location  = "apps/standard/example2/database-connection-secret.yaml"
      data = {
        MONGO_URI = replace(module.mongodbatlas_module.nonprod-connection-string, "mongodb+srv://", "mongodb+srv://${module.mongodbatlas_module.nonprod-user-username}:${module.mongodbatlas_module.nonprod-user-password}@")
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
