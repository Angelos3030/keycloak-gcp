variable "project_id" {
  description = "GCP project that hosts the monitoring resources."
  type        = string
}

variable "notification_channel_display_name" {
  description = "Display name for the practice email notification channel."
  type        = string
}

variable "notification_email" {
  description = "Email address that receives practice monitoring alerts."
  type        = string
}

variable "keycloak_host" {
  description = "Public Keycloak hostname monitored by the uptime check."
  type        = string
}