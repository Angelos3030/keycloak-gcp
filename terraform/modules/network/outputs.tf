output "network_id" {
  description = "The ID of the VPC network."
  value       = google_compute_network.vpc_network.id
}

output "subnet_id" {
  description = "The ID of the GKE subnet."
  value       = google_compute_subnetwork.subnet.id
}

output "psc_subnet_id" {
  description = "The ID of the subnet used for Private Service Connect endpoints."
  value       = google_compute_subnetwork.psc.id
}

output "pods_range_name" {
  description = "The secondary range name used by GKE Pods."
  value       = google_compute_subnetwork.subnet.secondary_ip_range[0].range_name
}

output "services_range_name" {
  description = "The secondary range name used by GKE Services."
  value       = google_compute_subnetwork.subnet.secondary_ip_range[1].range_name
}