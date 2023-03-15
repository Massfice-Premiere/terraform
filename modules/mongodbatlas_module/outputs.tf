output "nonprod-connection-string" {
  value       = mongodbatlas_serverless_instance.nonprod-db.connection_strings_standard_srv
  description = "connection string for nonprod instance"
}

output "prod-connection-string" {
  value       = mongodbatlas_serverless_instance.prod-db.connection_strings_standard_srv
  description = "connection string for prod instance"
}
