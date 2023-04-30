locals {
  ingresses = {
    "3ef3ad68-c1ed-43e9-834a-3102cff3f64f" = {
      name         = "ingress"
      service_name = "todo-example"
      service_port = 80
      sub          = "example"
      location     = "apps/example/ingress.yaml"
    }
    "5f3fc375-482c-438f-a5c7-31681f0cd413" = {
      name         = "ingress"
      service_name = "todo-example"
      service_port = 80
      sub          = "example2"
      location     = "apps/example2/ingress.yaml"
    }
  }
}
