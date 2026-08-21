variable "project_id" {
  description = "GCP project that hosts the Cloud SQL resources."
  type        = string
}

variable "region" {
  description = "Region in which to create the Cloud SQL instance and PSC endpoint."
  type        = string
}

variable "instance_name" {
  description = "Name of the Cloud SQL PostgreSQL instance."
  type        = string
}

variable "database_version" {
  description = "Cloud SQL PostgreSQL version, for example POSTGRES_16."
  type        = string
}

variable "tier" {
  description = "Cloud SQL machine tier."
  type        = string
}

variable "availability_type" {
  description = "Cloud SQL availability mode: ZONAL or REGIONAL."
  type        = string
  default     = "REGIONAL"
}

variable "disk_size_gb" {
  description = "Initial SSD disk size in GB."
  type        = number
  default     = 20
}

variable "deletion_protection" {
  description = "Prevent Terraform from deleting the Cloud SQL instance."
  type        = bool
  default     = true
}

variable "database_name" {
  description = "Name of the Keycloak PostgreSQL database."
  type        = string
  default     = "keycloak"
}

variable "database_user_name" {
  description = "Name of the Keycloak PostgreSQL user."
  type        = string
  default     = "keycloak"
}

variable "backup_start_time" {
  description = "UTC time at which daily automated backups begin, in HH:MM format."
  type        = string
  default     = "03:00"
}

variable "retained_backups" {
  description = "Number of automated backups to retain."
  type        = number
  default     = 7
}

variable "transaction_log_retention_days" {
  description = "Number of days to retain transaction logs for point-in-time recovery."
  type        = number
  default     = 7
}

variable "maintenance_window_day" {
  description = "UTC maintenance weekday, from 1 (Monday) through 7 (Sunday)."
  type        = number
  default     = 7
}

variable "maintenance_window_hour" {
  description = "UTC hour at which the maintenance window starts."
  type        = number
  default     = 3
}

variable "psc_allowed_consumer_projects" {
  description = "Project IDs or numbers permitted to create PSC endpoints for this instance."
  type        = list(string)
}

variable "vpc_network_id" {
  description = "ID of the VPC network hosting the PSC endpoint."
  type        = string
}

variable "psc_subnet_id" {
  description = "ID of the subnet in which to reserve the PSC endpoint IP address."
  type        = string
}
