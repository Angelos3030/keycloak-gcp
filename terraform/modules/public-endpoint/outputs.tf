output "name_servers" {
  description = "Google nameservers used for Cloudflare delegation."
  value       = google_dns_managed_zone.keycloak_lab.name_servers
}

output "public_ip_address" {
  description = "Global public IP for the Keycloak load balancer."
  value       = google_compute_global_address.keycloak.address
}

output "public_ip_name" {
  description = "Global address resource name used by GKE Ingress."
  value       = google_compute_global_address.keycloak.name
}

output "keycloak_fqdn" {
  description = "Public Keycloak hostname without its trailing dot."
  value       = trimsuffix(google_dns_record_set.keycloak.name, ".")
}
