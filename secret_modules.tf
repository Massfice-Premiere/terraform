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
