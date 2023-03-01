output "private_key" {
  value       = tls_private_key.tls-key.private_key_openssh
  description = "private key for github access"
}

output "init-yaml" {
  value       = data.template_file.init-yaml.rendered
  description = "rendered init.yaml"
}
