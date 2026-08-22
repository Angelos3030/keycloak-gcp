module "network" {
  source                   = "./modules/network"
  vpc_name                 = var.vpc_name
  project_id               = var.project_id
  region                   = var.region
  auto_create_subnetworks  = var.auto_create_subnetworks
  subnet_name              = var.subnet_name
  subnet_ip_cidr_range     = var.subnet_ip_cidr_range
  psc_subnet_name          = var.psc_subnet_name
  psc_subnet_ip_cidr_range = var.psc_subnet_ip_cidr_range
  gke_pods_cidr_range      = var.gke_pods_cidr_range
  gke_services_cidr_range  = var.gke_services_cidr_range
  router_name              = var.router_name
  nat_name                 = var.nat_name
}

module "gke" {
  source = "./modules/gke"

  project_id               = var.project_id
  region                   = var.region
  service_account_name     = var.gke_service_account_name
  cluster_name             = var.gke_cluster_name
  remove_default_node_pool = var.gke_remove_default_node_pool
  initial_node_count       = var.gke_initial_node_count
  node_pool_name           = var.gke_system_node_pool_name
  system_node_min_count    = var.gke_system_node_min_count
  system_node_max_count    = var.gke_system_node_max_count
  workload_node_pool_name  = var.gke_workload_node_pool_name
  workload_node_min_count  = var.gke_workload_node_min_count
  workload_node_max_count  = var.gke_workload_node_max_count
  preemptible              = var.gke_preemptible
  machine_type             = var.gke_machine_type

  network_id          = module.network.network_id
  subnet_id           = module.network.subnet_id
  pods_range_name     = module.network.pods_range_name
  services_range_name = module.network.services_range_name

  master_ipv4_cidr_block     = var.master_ipv4_cidr_block
  master_authorized_networks = var.gke_master_authorized_networks
}

module "cloudsql" {
  source = "./modules/cloudsql"

  project_id                    = var.project_id
  region                        = var.region
  instance_name                 = var.cloudsql_instance_name
  database_version              = var.cloudsql_database_version
  tier                          = var.cloudsql_tier
  availability_type             = var.cloudsql_availability_type
  disk_size_gb                  = var.cloudsql_disk_size_gb
  database_name                 = var.cloudsql_database_name
  database_user_name            = var.cloudsql_database_user_name
  psc_allowed_consumer_projects = var.cloudsql_psc_allowed_consumer_projects

  vpc_network_id = module.network.network_id
  psc_subnet_id  = module.network.psc_subnet_id
}

module "public_endpoint" {
  source = "./modules/public-endpoint"

  project_id    = var.project_id
  dns_zone_name = var.dns_zone_name
  dns_name      = var.dns_name
  address_name  = var.address_name
  keycloak_fqdn = var.keycloak_fqdn
}

module "monitoring" {
  source = "./modules/monitoring"

  project_id                        = var.project_id
  notification_channel_display_name = var.notification_channel_display_name
  notification_email                = var.notification_email
  keycloak_host                     = module.public_endpoint.keycloak_fqdn
}
