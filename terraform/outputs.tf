output "cloudsql_database_name" {
  description = "Name of the Cloud SQL database used by Keycloak."
  value       = module.cloudsql.database_name
}

output "cloudsql_database_user_name" {
  description = "Name of the Cloud SQL database user used by Keycloak."
  value       = module.cloudsql.database_user_name
}

output "cloudsql_psc_endpoint_ip" {
  description = "Private PSC endpoint IP used by Keycloak."
  value       = module.cloudsql.psc_endpoint_ip_address
}

output "cloudsql_database_user_password" {
  description = "Generated password for the Keycloak database user."
  value       = module.cloudsql.database_user_password
  sensitive   = true
}

output "public_endpoint_name_servers" {
  description = "Google nameservers to configure in Cloudflare."
  value       = module.public_endpoint.name_servers
}

output "keycloak_public_ip_address" {
  description = "Global public IP for Keycloak."
  value       = module.public_endpoint.public_ip_address
}

output "keycloak_public_ip_name" {
  description = "Global address name referenced by GKE Ingress."
  value       = module.public_endpoint.public_ip_name
}

output "keycloak_fqdn" {
  description = "Public Keycloak hostname."
  value       = module.public_endpoint.keycloak_fqdn
}

output "monitoring_email_notification_channel_name" {
  description = "Resource name of the practice email notification channel."
  value       = module.monitoring.email_notification_channel_name
}
