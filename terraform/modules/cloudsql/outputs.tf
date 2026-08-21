output "instance_name" {
  description = "Name of the Cloud SQL instance."
  value       = google_sql_database_instance.keycloak.name
}

output "database_name" {
  description = "Name of the Keycloak database."
  value       = google_sql_database.keycloak.name
}

output "database_user_name" {
  description = "Name of the Keycloak database user."
  value       = google_sql_user.keycloak.name
}

output "database_user_password" {
  description = "Generated password for the Keycloak database user."
  value       = random_password.database_user.result
  sensitive   = true
}

output "psc_endpoint_ip_address" {
  description = "Private IP address Keycloak uses to reach Cloud SQL through PSC."
  value       = google_compute_address.psc_endpoint.address
}

output "psc_service_attachment_link" {
  description = "Cloud SQL producer service attachment consumed by the PSC forwarding rule."
  value       = google_sql_database_instance.keycloak.psc_service_attachment_link
}
