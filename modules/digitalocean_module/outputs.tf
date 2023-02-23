output "kubernetes_host" {
  value = digitalocean_kubernetes_cluster.kubernetes.endpoint
}

output "kubernetes_config" {
  value = digitalocean_kubernetes_cluster.kubernetes.kube_config
}

output "loadbalancer_id" {
  value = digitalocean_loadbalancer.loadbalancer.id
}

output "loadbalancer_name" {
  value = digitalocean_loadbalancer.loadbalancer.name
}
