terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
}

provider "digitalocean" {
  token = var.token
}

resource "digitalocean_kubernetes_cluster" "kubernetes" {
  region  = "fra1"
  name    = var.cluster_name
  version = "1.24.8-do.0"

  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-2gb"
    node_count = 3
  }
}

resource "digitalocean_loadbalancer" "loadbalancer" {
  name      = "${var.cluster_name}-loadbalancer"
  region    = "fra1"
  size      = "lb-small"
  algorithm = "round_robin"

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 80
    target_protocol = "http"

  }

  lifecycle {
    ignore_changes = [
      forwarding_rule,
    ]
  }
}

resource "digitalocean_domain" "domain" {
  name       = var.domain
  ip_address = digitalocean_loadbalancer.loadbalancer.ip
}

resource "digitalocean_record" "a-record" {
  domain = digitalocean_domain.domain.id
  type   = "A"
  name   = "*"
  value  = digitalocean_loadbalancer.loadbalancer.ip
}

# data "digitalocean_droplet" "droplets" {
#   for_each = {
#     for index, droplet in digitalocean_kubernetes_cluster.kubernetes.node_pool[0].nodes : droplet.droplet_id => droplet
#   }

#   id = each.value.droplet_id
# }
