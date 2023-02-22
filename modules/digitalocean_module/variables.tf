variable "token" {
  type        = string
  description = "token for connecting to digital ocean"
}

variable "cluster_name" {
  type        = string
  default     = "Kubernetes Cluster"
  description = "name of cluster"
}
