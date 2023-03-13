output "kubernetes_host" {
  value       = digitalocean_kubernetes_cluster.kubernetes.endpoint
  description = "kubernetes host"
}

output "kubernetes_config" {
  value       = digitalocean_kubernetes_cluster.kubernetes.kube_config
  description = "kubernetes kube config"
}

output "loadbalancer_id" {
  value       = digitalocean_loadbalancer.loadbalancer.id
  description = "loadbalancer id"
}

output "loadbalancer_name" {
  value       = digitalocean_loadbalancer.loadbalancer.name
  description = "loadbalancer name"
}

output "kubernetes_nodes_ips" {
  value = [
    data.digitalocean_droplet.kube-node-0.ipv4_address,
    data.digitalocean_droplet.kube-node-1.ipv4_address,
    data.digitalocean_droplet.kube-node-2.ipv4_address
  ]
  description = "kubernetes nodes ips"
}
