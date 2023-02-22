terraform {
  required_providers {
    digitaloacen = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitaloacen" {
  token = var.token
}

resource "digitalocean_kubernetes_cluster" "kubernetes" {
  region = "fra1"
  name   = var.cluster_name

  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-2gb"
    node_count = 3
  }
}
