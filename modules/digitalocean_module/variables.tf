variable "token" {
  type        = string
  description = "token for connecting to digital ocean"
}

variable "cluster_name" {
  type        = string
  default     = "k8s-cluster"
  description = "name of cluster"
}
