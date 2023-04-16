terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "1.8.1"
    }
  }
}

provider "mongodbatlas" {
  public_key  = var.public_key
  private_key = var.private_key
}

resource "mongodbatlas_project_ip_access_list" "ips" {
  project_id = var.project_id
  for_each   = var.ips_to_whitelist
  comment    = "Kubernetes node: ${each.value}"
  ip_address = each.value
}

resource "mongodbatlas_serverless_instance" "nonprod-db" {
  project_id                              = var.project_id
  name                                    = "${var.db_name}-nonprod"
  provider_settings_backing_provider_name = "AWS"
  provider_settings_provider_name         = "SERVERLESS"
  provider_settings_region_name           = "EU_WEST_1"
  continuous_backup_enabled               = false
  termination_protection_enabled          = false
}

resource "mongodbatlas_serverless_instance" "prod-db" {
  project_id                              = var.project_id
  name                                    = "${var.db_name}-prod"
  provider_settings_backing_provider_name = "AWS"
  provider_settings_provider_name         = "SERVERLESS"
  provider_settings_region_name           = "EU_WEST_1"
  continuous_backup_enabled               = true
  termination_protection_enabled          = true
}

resource "random_password" "nonprod-user-password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "prod-user-password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "mongodbatlas_database_user" "nonprod-user" {
  username           = "${var.db_name}-nonprod-user"
  password           = random_password.nonprod-user-password.result
  project_id         = var.project_id
  auth_database_name = "admin"

  roles {
    role_name     = "dbAdmin"
    database_name = mongodbatlas_serverless_instance.nonprod-db.name
  }
}

resource "mongodbatlas_database_user" "prod-user" {
  username           = "${var.db_name}-prod-user"
  password           = random_password.prod-user-password.result
  project_id         = var.project_id
  auth_database_name = "admin"

  roles {
    role_name     = "dbAdmin"
    database_name = mongodbatlas_serverless_instance.prod-db.name
  }
}

