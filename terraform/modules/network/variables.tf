variable "vpc_name" {
  description = "The name of the network."
  type        = string  
}

variable "region" {
  description = "The region in which to create the network."
  type        = string
}

variable "project_id" {
  description = "The ID of the project in which to create the network."
  type        = string
}
variable "auto_create_subnetworks" {
  description = "Whether GCP automatically creates subnets in every region."
  type        = bool
}
variable "subnet_ip_cidr_range" {
  description = "The IP CIDR range for the subnetwork."
  type        = string
}
variable "gke_pods_cidr_range" {
  description = "The IP CIDR range for GKE pods."
  type        = string
}

variable "gke_services_cidr_range" {
  description = "The IP CIDR range for GKE services."
  type        = string
}

variable "services_range_name" {
  description = "The name of the secondary IP range for GKE services."
  type        = string
  default     = "gke-services-secondary-range"
}

variable "subnet_name" {
  description = "The name of the subnetwork."
  type        = string
}
variable "router_name" {
  description = "The name of the Cloud Router."
  type        = string
}

variable "nat_name" {
  description = "The name of the Cloud NAT."
  type        = string
}