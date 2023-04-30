locals {
  secrets = {
    "da27c250-b85e-49f1-800f-30805d6a450b" = {
      name      = "database-connection-secret"
      namespace = "example"
      type      = "Opaque"
      location  = "apps/example/database-connection-secret.yaml"
      data = {
        MONGO_HOST     = module.mongodbatlas_module.prod-connection-string
        MONGO_PASSWORD = urlencode(module.mongodbatlas_module.prod-user-password)
        MONGO_URI      = replace(module.mongodbatlas_module.prod-connection-string, "mongodb+srv://", "mongodb+srv://${module.mongodbatlas_module.prod-user-username}:${urlencode(module.mongodbatlas_module.prod-user-password)}@")
        MONGO_USERNAME = module.mongodbatlas_module.prod-user-username
      }
    }

    "5d994b59-8334-4a18-a03a-54b3af856f31" = {
      name      = "database-connection-secret"
      namespace = "example2"
      type      = "Opaque"
      location  = "apps/example2/database-connection-secret.yaml"
      data = {
        MONGO_HOST     = module.mongodbatlas_module.nonprod-connection-string
        MONGO_PASSWORD = urlencode(module.mongodbatlas_module.nonprod-user-password)
        MONGO_URI      = replace(module.mongodbatlas_module.nonprod-connection-string, "mongodb+srv://", "mongodb+srv://${module.mongodbatlas_module.nonprod-user-username}:${urlencode(module.mongodbatlas_module.nonprod-user-password)}@")
        MONGO_USERNAME = module.mongodbatlas_module.nonprod-user-username
      }
    }

    "c2fed378-cf37-4d99-b758-22fc0471da75" = {
      name      = "pull-secret"
      namespace = "example"
      type      = "kubernetes.io/dockerconfigjson"
      location  = "apps/example/pull-secret.yaml"
      data = {
        ".dockerconfigjson" = jsonencode({
          auths = {
            "https://index.docker.io/v1/" = {
              auth = base64encode("${var.dockerhub_username}:${var.dockerhub_password}")
            }
          }
        })
      }
    }

    d346942f-a918-4c90-8812-0ba837aa8203 = {
      name      = "pull-secret"
      namespace = "example2"
      type      = "kubernetes.io/dockerconfigjson"
      location  = "apps/example2/pull-secret.yaml"
      data = {
        ".dockerconfigjson" = jsonencode({
          auths = {
            "https://index.docker.io/v1/" = {
              auth = base64encode("${var.dockerhub_username}:${var.dockerhub_password}")
            }
          }
        })
      }
    }
  }
}
