terraform {
  required_providers {
    sealedsecret = {
      source = "2ttech/sealedsecret"
    }
  }
}

resource "sealedsecret_raw_secrets" "secret" {
  name        = var.name
  namespace   = var.namespace
  certificate = var.sealing_certificate
  values      = var.data
}

data "template_file" "sealed-secret-yaml" {
  template = file("templates/sealed-secret.template.yaml")
  vars = {
    SECRET_NAME = var.name
    SECRET_TYPE = var.type
    SECRET_DATA = sealedsecret_raw_secrets.secret.encrypted_values
  }
}
