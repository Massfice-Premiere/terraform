variable "public_key" {
  type        = string
  description = "public key for connecting to mongodb atlas"
}

variable "private_key" {
  type        = string
  description = "private key for connecting to mongodb atlas"
}

variable "project_id" {
  type        = string
  description = "project id"
}

variable "ips_to_whitelist" {
  type        = list(string)
  description = "ip adresses to whitelist"
}

variable "db_name" {
  type        = string
  description = "db name"
}
