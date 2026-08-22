# Case Study Summary

## Purpose

This repository is a practice implementation created before the actual six-hour interview exercise. It demonstrates the intended architecture in a personal GCP project and records both successful outcomes and remaining production gaps.

## Completed

- Provisioned a custom VPC, GKE networking ranges, PSC endpoint subnet, Cloud Router and Cloud NAT with Terraform.
- Provisioned a regional GKE cluster with private nodes, authorized control-plane networks, Workload Identity, managed logging/monitoring and two autoscaled node pools.
- Provisioned Cloud SQL for PostgreSQL 16 with regional availability, no public IPv4 address, automated backups, PITR and a maintenance window.
- Connected Keycloak to Cloud SQL through a regional Private Service Connect endpoint.
- Deployed Keycloak 26.6.4 with three replicas using the Codecentric KeycloakX Helm chart.
- Added resource requests/limits, health and metrics endpoints, database readiness checking and a PodDisruptionBudget.
- Reserved a global public IP, created a delegated Cloud DNS zone and published the Keycloak A record.
- Exposed Keycloak through GKE Ingress and container-native NEGs.
- Enabled HTTP-to-HTTPS redirect and a valid Google-managed TLS certificate.
- Created a public HTTPS uptime check and email alert channel.
- Tested the uptime alert by scaling Keycloak to zero and restoring three replicas.
- Created a failed-login logs-based metric and alert policy for more than ten invalid credentials in a 60-second interval.
- Configured a demo realm, public OpenID Connect client and user.
- Successfully authenticated `https://www.keycloak.org/app/` against the deployed Keycloak instance.
- Added an idempotent PowerShell deployment script using `helm upgrade --install`.
- Added a GitHub Actions workflow for Terraform, Helm, Kubernetes manifest, PowerShell and documentation validation.
- Documented architecture, deployment, validation, operations and troubleshooting.

## Tested Evidence

- Three Keycloak pods reached `Ready` state.
- GKE Ingress backends reached `HEALTHY` state.
- `http://keycloak.lab.getvitrina.gr` returned a permanent HTTPS redirect.
- `https://keycloak.lab.getvitrina.gr` returned a valid response with HSTS.
- The managed certificate reached `Active` and chained to Google Trust Services.
- The OpenID Connect discovery endpoint returned successfully over validated TLS.
- The uptime failure generated a Cloud Monitoring incident and email notification.
- Keycloak emitted `LOGIN_ERROR` with `invalid_user_credentials` into GKE workload logs.
- The public Keycloak test application completed the Authorization Code login and displayed the authenticated user's identity.

## Pending Final Verification

- Confirm receipt of the failed-login alert email after generating more than ten matching failures in one aligned minute.

If this verification succeeds, update this section and add it to the tested evidence list. Do not claim the alert was tested solely because the Terraform resource exists.

## Known Gaps

- Terraform state remains local instead of using a protected GCS backend.
- There is no sanitized committed `terraform.tfvars.example`.
- Realm, client and user configuration is manual rather than managed as code.
- The deployment uses Kubernetes Secrets populated from local Terraform output rather than Secret Manager integration.
- The initial bootstrap administrator has not been replaced by a permanent named administrator with MFA.
- Parent DNS delegation is manual because the parent domain is managed outside GCP.
- A real database restore drill has not been executed.
- NetworkPolicies and broader policy enforcement are not configured.
- Dashboards, SLOs and capacity alerts are not yet implemented.

## Cost Position

The design intentionally demonstrates high availability rather than minimum sandbox cost. The main cost drivers are regional Cloud SQL (`db-custom-2-7680`), continuously running GKE nodes, the global load balancer and Cloud NAT. GKE uses `e2-medium` nodes and autoscaling, while Cloud SQL starts with a 20 GB SSD and disk autoresize.

For a disposable personal practice environment, costs can be reduced by destroying resources when not in use. Zonal Cloud SQL, fewer Keycloak replicas or smaller sizing would reduce cost but would no longer demonstrate the requested HA architecture.

## Production Follow-up

1. Configure a GCS Terraform backend and CI identity federation.
2. Add a reviewed CI/CD workflow with formatting, validation, planning and controlled apply/deploy stages.
3. Move credentials to Secret Manager and implement rotation.
4. Manage Keycloak configuration declaratively.
5. Add permanent administration, MFA and access reviews.
6. Run and record backup restoration, zonal failure and upgrade/rollback exercises.
7. Add SLOs, dashboards, capacity monitoring and security detection.

## Interview Explanation

The central design choice is separation of concerns. Terraform provisions long-lived GCP services and their relationships. Helm deploys the maintained Keycloak workload rather than duplicating a third-party chart with hand-written manifests. GKE-specific manifests configure managed load-balancer features that the chart references. PSC supplies a private database path without a public Cloud SQL address. Managed DNS, TLS and monitoring reduce operational burden while leaving explicit runbooks for upgrades and recovery.

The implementation is deliberately honest about PoC compromises. It demonstrates the required end-to-end functionality, while the documented gaps identify what must change before production use.
