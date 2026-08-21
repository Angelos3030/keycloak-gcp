resource "google_service_account" "default" {
  account_id   = var.service_account_name
  display_name = "Service Account"
}
resource "google_project_iam_member" "node_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.default.email}"
}
resource "google_project_iam_member" "node_artifact_registry_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.default.email}"
}

resource "google_project_iam_member" "node_monitoring_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.default.email}"
}

resource "google_project_iam_member" "node_monitoring_viewer" {
  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.default.email}"
}
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region
  project  = var.project_id

  network    = var.network_id
  subnetwork = var.subnet_id

  remove_default_node_pool = var.remove_default_node_pool
  initial_node_count       = var.initial_node_count
  deletion_protection      = false

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_networks

      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  release_channel {
    channel = "REGULAR"
  }

  logging_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "WORKLOADS",
    ]
  }

  monitoring_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "KUBELET",
      "CADVISOR",
    ]

    managed_prometheus {
      enabled = true
    }
  }
}

resource "google_container_node_pool" "systepool" {
  name       = var.node_pool_name
  location   = var.region
  cluster    = google_container_cluster.primary.name

  depends_on = [
    google_project_iam_member.node_artifact_registry_reader,
    google_project_iam_member.node_logging,
    google_project_iam_member.node_monitoring_metric_writer,
    google_project_iam_member.node_monitoring_viewer,
  ]

  autoscaling {
    total_min_node_count = var.system_node_min_count
    total_max_node_count = var.system_node_max_count
  }

  node_config {
    preemptible  = var.preemptible
    machine_type = var.machine_type

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.default.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }
}

resource "google_container_node_pool" "workloadpool" {
  name       = var.workload_node_pool_name
  location   = var.region
  cluster    = google_container_cluster.primary.name

  depends_on = [
    google_project_iam_member.node_artifact_registry_reader,
    google_project_iam_member.node_logging,
    google_project_iam_member.node_monitoring_metric_writer,
    google_project_iam_member.node_monitoring_viewer,
  ]

  autoscaling {
    total_min_node_count = var.workload_node_min_count
    total_max_node_count = var.workload_node_max_count
  }

  node_config {
    preemptible  = var.preemptible
    machine_type = var.machine_type

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.default.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }
}