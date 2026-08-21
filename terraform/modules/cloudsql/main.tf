resource "random_password" "database_user" {
  length  = 32
  special = true
}

resource "google_sql_database_instance" "keycloak" {
  project             = var.project_id
  name                = var.instance_name
  region              = var.region
  database_version    = var.database_version
  deletion_protection = var.deletion_protection

  settings {
    tier              = var.tier
    edition           = "ENTERPRISE"
    availability_type = var.availability_type

    disk_autoresize = true
    disk_size       = var.disk_size_gb
    disk_type       = "PD_SSD"

    backup_configuration {
      enabled                        = true
      start_time                     = var.backup_start_time
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = var.transaction_log_retention_days

      backup_retention_settings {
        retained_backups = var.retained_backups
        retention_unit   = "COUNT"
      }
    }

    maintenance_window {
      day          = var.maintenance_window_day
      hour         = var.maintenance_window_hour
      update_track = "stable"
    }

    ip_configuration {
      ipv4_enabled = false

      psc_config {
        psc_enabled               = true
        allowed_consumer_projects = var.psc_allowed_consumer_projects
      }
    }
  }
}

resource "google_sql_database" "keycloak" {
  project  = var.project_id
  name     = var.database_name
  instance = google_sql_database_instance.keycloak.name
  charset  = "UTF8"
}

resource "google_sql_user" "keycloak" {
  project  = var.project_id
  name     = var.database_user_name
  instance = google_sql_database_instance.keycloak.name
  password = random_password.database_user.result
}

resource "google_compute_address" "psc_endpoint" {
  name         = "${var.instance_name}-psc-ip"
  project      = var.project_id
  region       = var.region
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  subnetwork   = var.psc_subnet_id
}

resource "google_compute_forwarding_rule" "psc_endpoint" {
  name                  = "${var.instance_name}-psc"
  project               = var.project_id
  region                = var.region
  network               = var.vpc_network_id
  subnetwork            = var.psc_subnet_id
  ip_address            = google_compute_address.psc_endpoint.id
  target                = google_sql_database_instance.keycloak.psc_service_attachment_link
  load_balancing_scheme = ""
}
