variable "project_id" {
  description = "The ID of the project in which to create resources."
  type        = string
}

variable "dns_zone_name" {
  description = "The name of the DNS zone."
  type        = string
}

variable "dns_name" {
  description = "The DNS name of the zone."
  type        = string
}

variable "address_name" {
  description = "The name of the global address."
  type        = string
}

variable "keycloak_fqdn" {
  description = "The fully qualified domain name for the Keycloak instance."
  type        = string
}