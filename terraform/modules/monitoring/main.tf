resource "google_monitoring_notification_channel" "email" {
  project      = var.project_id
  display_name = var.notification_channel_display_name
  type         = "email"

  labels = {
    email_address = var.notification_email
  }

  force_delete = false
}
resource "google_monitoring_uptime_check_config" "keycloak_https" {
  project            = var.project_id
  display_name       = "Keycloak public HTTPS"
  timeout            = "10s"
  period             = "60s"
  checker_type       = "STATIC_IP_CHECKERS"
  log_check_failures = true

  http_check {
    request_method = "GET"
    path           = "/realms/master/.well-known/openid-configuration"
    port           = "443"
    use_ssl        = true
    validate_ssl   = true
  }

  monitored_resource {
    type = "uptime_url"

    labels = {
      project_id = var.project_id
      host       = var.keycloak_host
    }
  }
}

resource "google_monitoring_alert_policy" "keycloak_public_uptime_failure" {
  display_name = "keycloak_public_uptime_failure"
  combiner     = "OR"
  notification_channels = [
    google_monitoring_notification_channel.email.name,
  ]

  conditions {
    display_name = "Keycloak uptime check failing"
    condition_threshold {
      filter          = "metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\" AND resource.type=\"uptime_url\" AND metric.label.check_id=\"${google_monitoring_uptime_check_config.keycloak_https.uptime_check_id}\""
      duration        = "60s"
      comparison      = "COMPARISON_LT"
      threshold_value = 1
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_FRACTION_TRUE"
      }
    }
  }

  user_labels = {
    project_id = var.project_id
  }
}

resource "google_logging_metric" "keycloak_failed_logins" {
  project     = var.project_id
  description = "Counts Keycloak login failures caused by invalid user credentials"
  name        = "keycloak_failed_logins"
  filter      = <<-EOT
    resource.type="k8s_container"
    AND resource.labels.namespace_name="keycloak"
    AND resource.labels.container_name="keycloak"
    AND textPayload:"type=\"LOGIN_ERROR\""
    AND textPayload:"error=\"invalid_user_credentials\""
  EOT
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
  disabled = false
}

resource "google_monitoring_alert_policy" "google_logging_metric_keycloak_failed_logins" {
  display_name = "keycloak_failed_logins"
  combiner     = "OR"
  notification_channels = [
    google_monitoring_notification_channel.email.name,
  ]
  conditions {
    display_name = "Keycloak failed logins"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/keycloak_failed_logins\" AND resource.type=\"k8s_container\""
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = 10
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_SUM"
        cross_series_reducer = "REDUCE_SUM"
      }
    }
  }

  user_labels = {
    project_id = var.project_id
  }
}