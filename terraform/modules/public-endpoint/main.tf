resource "google_dns_managed_zone" "keycloak_lab" {
  project     = var.project_id
  name        = var.dns_zone_name
  dns_name    = var.dns_name
  description = "Public DNS zone for the Keycloak practice environment"
  visibility  = "public"
}

resource "google_compute_global_address" "keycloak" {
  project      = var.project_id
  name         = var.address_name
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

resource "google_dns_record_set" "keycloak" {
  project      = var.project_id
  managed_zone = google_dns_managed_zone.keycloak_lab.name
  name         = var.keycloak_fqdn
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.keycloak.address]
}