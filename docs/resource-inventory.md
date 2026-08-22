# Resource Inventory

## Inventory Scope

This inventory records only resources observed in the live practice environment or present in Terraform state on 22 August 2026. It does not list proposed or future resources.

`Service / tier` describes deployed configuration, not Google Cloud billing-catalog SKU IDs. Billing SKU identifiers and prices vary by region and catalog revision and should be retrieved from Cloud Billing for a formal cost report.

## Resource Hierarchy

| Level | Display name | ID | Notes |
|---|---|---|---|
| Organization | Not managed here | `757263224637` | Parent of the practice folder |
| Folder | `keycloak-practice` | `262566544765` | Contains the practice project |
| Project | `Keycloak Practice` | `keycloak-practice-01` | Hosts all managed GCP resources |
| Project number | N/A | `808571009227` | Numeric Google project identity |
| Primary region | N/A | `us-central1` | GKE, Cloud SQL, PSC and VPC resources |

No folder or organization resources are created by this repository. Their identifiers only document project placement.

## Service and Sizing Summary

| Component | Google service | Service / tier | Scope | HA or scaling |
|---|---|---|---|---|
| Kubernetes control plane | GKE Standard | Regional, Regular channel | `us-central1` | Regional managed control plane |
| System nodes | Compute Engine through GKE | `e2-medium` | `us-central1` | Autoscaling 1-2 total nodes |
| Workload nodes | Compute Engine through GKE | `e2-medium` | `us-central1` | Autoscaling 1-3 total nodes |
| Keycloak | GKE workload | Keycloak `26.6.4`, chart `keycloakx-7.2.3` | `keycloak` namespace | 3 replicas; PDB minimum 2 |
| PostgreSQL | Cloud SQL | PostgreSQL 16, Enterprise, `db-custom-2-7680` | `us-central1` | `REGIONAL` availability |
| Database disk | Cloud SQL storage | 20 GB `PD_SSD`, autoresize | `us-central1` | Daily backup and PITR |
| Public endpoint | Cloud Load Balancing | Global external Application Load Balancer | Global | Google-managed service |
| TLS | GKE ManagedCertificate | Google-managed public certificate | Global | Managed issuance/renewal |
| DNS | Cloud DNS | Public managed zone | Global | Google authoritative nameservers |
| Database path | Private Service Connect | Regional internal endpoint | `us-central1` | No Cloud SQL public IPv4 |
| Egress | Cloud NAT | Auto-allocated NAT addresses | `us-central1` | Private-node outbound access |
| Monitoring | Cloud Monitoring/Logging | Uptime, alerts and log metric | Global | Multi-location checkers |

## Terraform-Managed GCP Resources

| Area | Terraform type | Resource name | Location | Purpose |
|---|---|---|---|---|
| Network | `google_compute_network` | `keycloak-vpc` | Global | Custom-mode VPC |
| Network | `google_compute_subnetwork` | `gke-subnet` | `us-central1` | Node range `10.10.0.0/20` |
| Network | Secondary range | `gke-pods-secondary-range` | `us-central1` | Pods `10.20.0.0/16` |
| Network | Secondary range | `gke-services-secondary-range` | `us-central1` | Services `10.30.0.0/20` |
| Network | `google_compute_subnetwork` | `psc-endpoints-subnet` | `us-central1` | PSC range `10.11.0.0/28` |
| Egress | `google_compute_router` | `keycloak-router` | `us-central1` | Cloud NAT router |
| Egress | `google_compute_router_nat` | `keycloak-nat` | `us-central1` | Private-node egress |
| GKE | `google_container_cluster` | `keycloak-gke` | `us-central1` | Regional private-node cluster |
| GKE | `google_container_node_pool` | `system-pool` | `us-central1` | `e2-medium`, autoscaling 1-2 |
| GKE | `google_container_node_pool` | `workload-pool` | `us-central1` | `e2-medium`, autoscaling 1-3 |
| IAM | `google_service_account` | `gke-node-sa` | Project | Dedicated node identity |
| Cloud SQL | `google_sql_database_instance` | `keycloak-postgres` | `us-central1` | Regional PostgreSQL 16 |
| Cloud SQL | `google_sql_database` | `keycloak` | Instance | Application database |
| Cloud SQL | `google_sql_user` | `keycloak` | Instance | Application DB user |
| PSC | `google_compute_address` | `keycloak-postgres-psc-ip` | `us-central1` | Internal IP `10.11.0.2` |
| PSC | `google_compute_forwarding_rule` | `keycloak-postgres-psc` | `us-central1` | Cloud SQL service attachment |
| Public IP | `google_compute_global_address` | `keycloak-public-ip` | Global | External IP `136.68.14.25` |
| DNS | `google_dns_managed_zone` | `keycloak-lab` | Global | Public `lab.getvitrina.gr.` zone |
| DNS | `google_dns_record_set` | `keycloak.lab.getvitrina.gr.` | Global | A record to `136.68.14.25`, TTL 300 |
| Monitoring | `google_monitoring_notification_channel` | `Keycloak practice alerts` | Project | Email destination |
| Monitoring | `google_monitoring_uptime_check_config` | `Keycloak public HTTPS` | Global | 60-second HTTPS check; 10-second timeout |
| Monitoring | `google_monitoring_alert_policy` | `keycloak_public_uptime_failure` | Project | Availability alert |
| Logging | `google_logging_metric` | `keycloak_failed_logins` | Project | Invalid-credential counter |
| Monitoring | `google_monitoring_alert_policy` | `keycloak_failed_logins` | Project | More than 10 failures/minute |

Terraform also manages `random_password.database_user`. It stores the generated database password in Terraform state; it is not a standalone GCP resource.

## GKE and Helm Resources

| Kind | Namespace | Name | Purpose |
|---|---|---|---|
| Helm release | `keycloak` | `keycloak` | KeycloakX release; revision 6 when inventoried |
| StatefulSet | `keycloak` | `keycloak-keycloakx` | Three Keycloak replicas |
| Service | `keycloak` | `keycloak-keycloakx-headless` | StatefulSet discovery |
| Service | `keycloak` | `keycloak-keycloakx-http` | ClusterIP frontend and NEG source |
| Ingress | `keycloak` | `keycloak-keycloakx` | Public GKE load balancer |
| BackendConfig | `keycloak` | `keycloak-backend-config` | `/health/ready` on port 9000 |
| FrontendConfig | `keycloak` | `keycloak-frontend-config` | HTTP-to-HTTPS redirect |
| ManagedCertificate | `keycloak` | `keycloak-certificate` | Public TLS certificate |
| PodDisruptionBudget | `keycloak` | `keycloak-keycloakx` | `minAvailable: 2` |
| Secret | `keycloak` | `keycloak-db-credentials` | DB password; value omitted |
| Secret | `keycloak` | `keycloak-admin-credentials` | Bootstrap password; value omitted |

The following GKE-generated resources were also observed live. They are not directly managed by a Terraform resource in this repository:

| Generated resource | Location | Observed configuration |
|---|---|---|
| `gke-keycloak-gke-77d922c7-pe-subnet` | `us-central1` | GKE control-plane subnet `172.16.0.0/28` |

The following GKE Ingress forwarding rules were observed live:

| Generated forwarding rule | Address | Port | Purpose |
|---|---|---|---|
| `k8s2-fr-ecpzhcyw-keycloak-keycloak-keycloakx-6w02kab9` | `136.68.14.25` | 80 | HTTP redirect |
| `k8s2-fs-ecpzhcyw-keycloak-keycloak-keycloakx-6w02kab9` | `136.68.14.25` | 443 | HTTPS frontend |

Generated backend services, URL maps, target proxies, NEGs and firewall rules remain owned by GKE and must not be independently managed by Terraform.

## DNS Nameservers

```text
ns-cloud-c1.googledomains.com.
ns-cloud-c2.googledomains.com.
ns-cloud-c3.googledomains.com.
ns-cloud-c4.googledomains.com.
```

The parent-zone NS delegation is managed outside this repository.

## IAM Roles

Service account:

```text
gke-node-sa@keycloak-practice-01.iam.gserviceaccount.com
```

| Role | Purpose |
|---|---|
| `roles/artifactregistry.reader` | Pull container images from Artifact Registry |
| `roles/logging.logWriter` | Send system and workload logs |
| `roles/monitoring.metricWriter` | Write node/workload metrics |
| `roles/monitoring.viewer` | Support GKE monitoring integration |

These are project-level bindings for the dedicated node service account. The repository creates no Owner or Editor bindings.

Workload Identity pool:

```text
keycloak-practice-01.svc.id.goog
```

No Keycloak-specific Google service account binding exists in Terraform state.

## Buckets and Terraform State

| Purpose | Bucket | Status |
|---|---|---|
| Terraform remote state | None | Not configured; state is local |
| Application object storage | None | Not created |
| Backup export | None | Not created |

No GCS buckets existed in `keycloak-practice-01` when inventoried.

## Validation Commands

```powershell
terraform -chdir=terraform state list

gcloud projects describe keycloak-practice-01
gcloud container clusters describe keycloak-gke --region=us-central1 --project=keycloak-practice-01
gcloud container node-pools list --cluster=keycloak-gke --region=us-central1 --project=keycloak-practice-01
gcloud sql instances describe keycloak-postgres --project=keycloak-practice-01
gcloud compute addresses list --project=keycloak-practice-01
gcloud dns record-sets list --zone=keycloak-lab --project=keycloak-practice-01
gcloud logging metrics describe keycloak_failed_logins --project=keycloak-practice-01
gcloud monitoring policies list --project=keycloak-practice-01
gcloud storage buckets list --project=keycloak-practice-01

kubectl get statefulset,service,ingress,backendconfig,frontendconfig,managedcertificate,pdb -n keycloak
helm list -n keycloak
```
