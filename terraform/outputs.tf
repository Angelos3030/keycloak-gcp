output "cloudsql_database_name" {
  description = "Name of the Cloud SQL database used by Keycloak."
  value       = module.cloudsql.database_name
}

output "cloudsql_database_user_name" {
  description = "Name of the Cloud SQL database user used by Keycloak."
  value       = module.cloudsql.database_user_name
}

output "cloudsql_database_user_password" {
  description = "Generated password for the Cloud SQL database user."
  value       = module.cloudsql.database_user_password
  sensitive   = true
}

output "cloudsql_psc_endpoint_ip_address" {
  description = "Private PSC IP address Keycloak uses as its PostgreSQL host."
  value       = module.cloudsql.psc_endpoint_ip_address
}