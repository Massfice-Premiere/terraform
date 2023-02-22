output "kubernetes_host" {
  value = digitalocean_kubernetes_cluster.kubernetes.endpoint
}

output "kubernetes_token" {
  value = digitalocean_kubernetes_cluster.kubernetes.kube_config[0].token
}

output "kubernetes_certificate" {
  value = base64decode(digitalocean_kubernetes_cluster.kubernetes.kube_config[0].cluster_ca_certificate)
}

output "loadbalancer_ip" {
  value = digitalocean_loadbalancer.loadbalancer.ip
}
