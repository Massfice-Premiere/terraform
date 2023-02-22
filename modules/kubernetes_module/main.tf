terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.1"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = var.kubernetes_host
    token                  = var.kubernetes_host
    cluster_ca_certificate = var.kubernetes_certificate
  }
}
