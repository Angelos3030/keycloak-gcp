resource "google_compute_network" "vpc_network" {
  name                    = var.vpc_name
  auto_create_subnetworks = var.auto_create_subnetworks
}

resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_ip_cidr_range
  region        = var.region 
  network       = google_compute_network.vpc_network.id
  project       = var.project_id
  private_ip_google_access = true

 secondary_ip_range {
    range_name    = "gke-pods-secondary-range"
    ip_cidr_range = var.gke_pods_cidr_range
  }

    secondary_ip_range {
        range_name    = "gke-services-secondary-range"
        ip_cidr_range = var.gke_services_cidr_range
    }
}

resource "google_compute_subnetwork" "psc" {
  name          = var.psc_subnet_name
  ip_cidr_range = var.psc_subnet_ip_cidr_range
  region        = var.region
  network       = google_compute_network.vpc_network.id
  project       = var.project_id
}

resource "google_compute_router" "nat" {
  name    = var.router_name
  network = google_compute_network.vpc_network.id
  region  = var.region
  project = var.project_id
}

resource "google_compute_router_nat" "nat" {
  name                               = var.nat_name
  router                             = google_compute_router.nat.name
  region                             = var.region
  project                            = var.project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}