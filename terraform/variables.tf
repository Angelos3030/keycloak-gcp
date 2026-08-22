variable "project_id" {
  description = "The ID of the project in which to create resources."
  type        = string
}

variable "region" {
  description = "The region in which to create resources."
  type        = string
}

variable "subnet_ip_cidr_range" {
  description = "The IP CIDR range for the subnetwork."

  type = string
}

variable "gke_pods_cidr_range" {
  description = "The IP CIDR range for GKE pods."
  type        = string
}
variable "gke_services_cidr_range" {
  description = "The IP CIDR range for GKE services."
  type        = string
}



variable "auto_create_subnetworks" {
  description = "Whether GCP automatically creates subnets in every region."
  type        = bool
}
variable "vpc_name" {
  description = "The name of the VPC network."
  type        = string
}

variable "subnet_name" {
  description = "The name of the subnetwork."
  type        = string
}

variable "psc_subnet_name" {
  description = "The name of the subnet that hosts Private Service Connect endpoints."
  type        = string
}

variable "psc_subnet_ip_cidr_range" {
  description = "The IP CIDR range for the Private Service Connect endpoint subnet."
  type        = string
}

variable "gke_pods_secondary_range_name" {
  description = "The name of the secondary IP range for GKE pods."
  type        = string
  default     = "gke-pods-secondary-range"
}

variable "gke_services_secondary_range_name" {
  description = "The name of the secondary IP range for GKE services."
  type        = string
  default     = "gke-services-secondary-range"
}

variable "master_ipv4_cidr_block" {
  description = "Non-overlapping /28 CIDR range for the private GKE control plane."
  type        = string
}

variable "gke_master_authorized_networks" {
  description = "Public CIDR ranges allowed to access the GKE control-plane endpoint."
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
}

variable "gke_service_account_name" {
  description = "Account ID for the GKE node service account."
  type        = string
}

variable "gke_cluster_name" {
  description = "Name of the GKE cluster."
  type        = string
}

variable "gke_remove_default_node_pool" {
  description = "Whether to remove the default GKE node pool."
  type        = bool
}

variable "gke_initial_node_count" {
  description = "Temporary node count used while GKE creates and removes its default node pool."
  type        = number
}

variable "gke_system_node_pool_name" {
  description = "Name of the GKE system node pool."
  type        = string
}

variable "gke_system_node_min_count" {
  description = "Minimum total node count for the GKE system node pool."
  type        = number
}

variable "gke_system_node_max_count" {
  description = "Maximum total node count for the GKE system node pool."
  type        = number
}

variable "gke_workload_node_pool_name" {
  description = "Name of the GKE workload node pool."
  type        = string
}

variable "gke_workload_node_min_count" {
  description = "Minimum total node count for the GKE workload node pool."
  type        = number
}

variable "gke_workload_node_max_count" {
  description = "Maximum total node count for the GKE workload node pool."
  type        = number
}

variable "gke_preemptible" {
  description = "Whether GKE nodes are preemptible."
  type        = bool
}

variable "gke_machine_type" {
  description = "Compute Engine machine type for GKE nodes."
  type        = string
}
variable "router_name" {
  description = "The Cloud Router name for the development environment."
  type        = string
}

variable "nat_name" {
  description = "The Cloud NAT name for the development environment."
  type        = string
}

variable "cloudsql_instance_name" {
  description = "Name of the Cloud SQL PostgreSQL instance."
  type        = string
}

variable "cloudsql_database_version" {
  description = "Cloud SQL PostgreSQL version."
  type        = string
}

variable "cloudsql_tier" {
  description = "Cloud SQL machine tier."
  type        = string
}

variable "cloudsql_availability_type" {
  description = "Cloud SQL availability mode."
  type        = string
}

variable "cloudsql_disk_size_gb" {
  description = "Initial Cloud SQL SSD disk size in GB."
  type        = number
}

variable "cloudsql_database_name" {
  description = "Name of the Keycloak PostgreSQL database."
  type        = string
}

variable "cloudsql_database_user_name" {
  description = "Name of the Keycloak PostgreSQL user."
  type        = string
}

variable "cloudsql_psc_allowed_consumer_projects" {
  description = "Projects allowed to create PSC endpoints for Cloud SQL."
  type        = list(string)
}
variable "dns_zone_name" {
  description = "Cloud DNS managed-zone resource name."
  type        = string
}

variable "dns_name" {
  description = "Delegated public DNS suffix, ending with a dot."
  type        = string
}

variable "address_name" {
  description = "Name of the global static IP for Keycloak."
  type        = string
}

variable "keycloak_fqdn" {
  description = "Public Keycloak FQDN, ending with a dot."
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
