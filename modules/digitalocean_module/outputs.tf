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

output "node0_ip" {
  value       = data.digitalocean_droplet.kube-node-0.ipv4_address
  description = "kubernetes node 0 ip"
}

output "node1_ip" {
  value       = data.digitalocean_droplet.kube-node-1.ipv4_address
  description = "kubernetes node 1 ip"
}

output "node2_ip" {
  value       = data.digitalocean_droplet.kube-node-2.ipv4_address
  description = "kubernetes node 2 ip"
}

