output "secret" {
  value = {
    location = var.location,
    yaml     = template_file.sealed-secret-yaml
    id       = "${var.namespace}/${var.name}.yaml"
  }
  description = "generated secret with path"
}
