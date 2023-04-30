output "private_key" {
  value       = tls_private_key.tls-key.private_key_openssh
  description = "private key for github access"
}

output "init-yaml" {
  value       = local.init_yaml
  description = "rendered init.yaml"
}

output "projects-yaml" {
  value       = local.projects_yaml
  description = "projects.yaml"
}

output "application-set-yaml" {
  value       = local.application_set_yaml
  description = "application-set.yaml"
}
