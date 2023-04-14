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
  github_argocd-repo  = var.github_argo_repo

  providers = {
    github       = github.github
    sealedsecret = sealedsecret.sealedsecret
  }
}
