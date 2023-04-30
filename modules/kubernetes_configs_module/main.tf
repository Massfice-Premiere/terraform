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

  secrets = {
    "da27c250-b85e-49f1-800f-30805d6a450b" = {
      name      = "database-connection-secret"
      namespace = "example"
      type      = "Opaque"
      location  = "apps/example/database-connection-secret.yaml"
      data = {
        MONGO_HOST     = var.mongo_host_prod
        MONGO_PASSWORD = var.mongo_password_prod
        MONGO_URI      = var.mongo_uri_prod
        MONGO_USERNAME = var.mongo_username_prod
      }
    }

    "5d994b59-8334-4a18-a03a-54b3af856f31" = {
      name      = "database-connection-secret"
      namespace = "example2"
      type      = "Opaque"
      location  = "apps/example2/database-connection-secret.yaml"
      data = {
        MONGO_HOST     = var.mongo_host_nonprod
        MONGO_PASSWORD = var.mongo_password_nonprod
        MONGO_URI      = var.mongo_uri_nonprod
        MONGO_USERNAME = var.mongo_username_nonprod
      }
    }

    "c2fed378-cf37-4d99-b758-22fc0471da75" = {
      name      = "pull-secret"
      namespace = "example"
      type      = "kubernetes.io/dockerconfigjson"
      location  = "apps/example/pull-secret.yaml"
      data = {
        ".dockerconfigjson" = var.docker_config
      }
    }

    "d346942f-a918-4c90-8812-0ba837aa8203" = {
      name      = "pull-secret"
      namespace = "example2"
      type      = "kubernetes.io/dockerconfigjson"
      location  = "apps/example2/pull-secret.yaml"
      data = {
        ".dockerconfigjson" = var.docker_config
      }
    }
  }
}
