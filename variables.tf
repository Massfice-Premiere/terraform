variable "digitalocean_token" {
  type        = string
  description = "token for connecting to digitalocean"
}

variable "letsencrypt_email" {
  type        = string
  description = "email for ssl certificate"
}

variable "domain" {
  type        = string
  description = "domain which point to cluster loadbalancer"
}

