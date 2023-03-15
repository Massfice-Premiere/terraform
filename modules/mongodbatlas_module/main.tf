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

