output "nonprod-connection-string" {
  value       = mongodbatlas_serverless_instance.nonprod-db.connection_strings_standard_srv
  description = "connection string for nonprod instance"
}

output "nonprod-user-username" {
  value       = mongodbatlas_database_user.nonprod-user.username
  description = "username of nonprod database user"
}

output "nonprod-user-password" {
  value       = random_password.nonprod-user-password.result
  description = "password of nonprod database user"
}

output "prod-connection-string" {
  value       = mongodbatlas_serverless_instance.prod-db.connection_strings_standard_srv
  description = "connection string for prod instance"
}

output "prod-user-username" {
  value       = mongodbatlas_database_user.prod-user.username
  description = "username of prod database user"
}

output "prod-user-password" {
  value       = random_password.prod-user-password.result
  description = "password of prod database user"
}
