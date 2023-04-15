module "subdomain_module" {
  source = "./modules/subdomain_module"

  for_each = {
    example_subdomain = {
      name         = "ingress"
      service_name = "todo-example"
      service_port = 80
      sub          = "example"
      location     = "apps/standard/example/ingress.yaml"
    }
    example_subdomain_2 = {
      name         = "ingress"
      service_name = "todo-example"
      service_port = 80
      sub          = "example2"
      location     = "apps/standard/example2/ingress.yaml"
    }
  }

  name               = each.value.name
  service_name       = each.value.service_name
  service_port       = each.value.service_port
  sub                = each.value.sub
  location           = each.value.location
  github_argocd-repo = var.github_argo_repo
  domain             = var.domain

  providers = {
    github = github.github
  }
}
