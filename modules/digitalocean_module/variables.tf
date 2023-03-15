variable "token" {
  type        = string
  description = "token for connecting to digital ocean"
}

variable "cluster_name" {
  type        = string
  description = "name of cluster"
}

variable "domain" {
  type        = string
  description = "domain which point to cluster loadbalancer"
}
