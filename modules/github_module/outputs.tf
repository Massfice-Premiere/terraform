output "private_key" {
  value       = tls_private_key.tls-key.private_key_pem
  description = "private key for github access"
}
