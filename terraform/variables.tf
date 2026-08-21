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