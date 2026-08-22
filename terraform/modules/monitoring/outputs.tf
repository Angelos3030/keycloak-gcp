output "email_notification_channel_name" {
  description = "Resource name of the email notification channel."
  value       = google_monitoring_notification_channel.email.name
}
output "google_monitoring_uptime_check_config_keycloak_https_uptime_check_id" {
  description = "Resource name of the Keycloak public HTTPS uptime check."
  value       = google_monitoring_uptime_check_config.keycloak_https.uptime_check_id
}