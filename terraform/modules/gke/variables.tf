variable "project_id" {
  description = "The GCP project ID hosting the GKE cluster."
  type        = string
}

variable "service_account_name" {
  description = "The account ID for the GKE node service account."
  type        = string
}

variable "cluster_name" {
  description = "The name of the GKE cluster."
  type        = string
}

variable "region" {
  description = "The region where the GKE cluster is created."
  type        = string
}

variable "network_id" {
  description = "The VPC network ID for the GKE cluster."
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID for GKE nodes."
  type        = string
}

variable "pods_range_name" {
  description = "The secondary subnet range name for Pod IP addresses."
  type        = string
}

variable "services_range_name" {
  description = "The secondary subnet range name for Service ClusterIP addresses."
  type        = string
}

variable "master_ipv4_cidr_block" {
  description = "Non-overlapping /28 CIDR range for the private GKE control plane."
  type        = string
}

variable "master_authorized_networks" {
  description = "Public CIDR ranges allowed to access the GKE control-plane endpoint."
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
}

variable "remove_default_node_pool" {
  description = "Whether to remove the automatically created default node pool."
  type        = bool
}

variable "initial_node_count" {
  description = "Temporary initial node count while GKE creates then removes its default node pool."
  type        = number
}

variable "node_pool_name" {
  description = "The name of the system node pool."
  type        = string
}

variable "system_node_min_count" {
  description = "Minimum total number of nodes in the system node pool."
  type        = number
}

variable "system_node_max_count" {
  description = "Maximum total number of nodes in the system node pool."
  type        = number
}

variable "workload_node_pool_name" {
  description = "The name of the workload node pool."
  type        = string
}

variable "workload_node_min_count" {
  description = "Minimum total number of nodes in the workload node pool."
  type        = number
}

variable "workload_node_max_count" {
  description = "Maximum total number of nodes in the workload node pool."
  type        = number
}

variable "preemptible" {
  description = "Whether GKE nodes use preemptible VMs."
  type        = bool
}

variable "machine_type" {
  description = "The Compute Engine machine type for GKE nodes."
  type        = string
}