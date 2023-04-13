output "secret" {
  value = {
    location = var.location,
    yaml     = data.template_file.sealed-secret-yaml.rendered
    id       = "${var.namespace}/${var.name}.yaml"
  }
  description = "generated secret with path"
}
