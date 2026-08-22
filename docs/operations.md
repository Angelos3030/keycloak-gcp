# Operations Runbook

## Operating Principles

- Test changes in a non-production environment first.
- Pin Terraform provider, Helm chart and Keycloak image versions.
- Create and verify a database backup before schema-changing upgrades.
- Keep at least two Keycloak replicas available during voluntary maintenance.
- Never use Terraform state, Kubernetes Secret output or terminal history as a credential-sharing mechanism.
- Record the start time, operator, change, validation result and rollback decision for each maintenance event.

## Routine Health Checks

```powershell
kubectl get nodes
kubectl get pods -n keycloak -o wide
kubectl get statefulset,poddisruptionbudget -n keycloak
kubectl rollout status statefulset/keycloak-keycloakx -n keycloak --timeout=10m
helm status keycloak -n keycloak
```

External validation:

```powershell
Resolve-DnsName keycloak.lab.getvitrina.gr
curl.exe -I http://keycloak.lab.getvitrina.gr
curl.exe -f https://keycloak.lab.getvitrina.gr/realms/master/.well-known/openid-configuration
```

Database and PSC validation:

```powershell
gcloud sql instances describe keycloak-postgres `
  --project=keycloak-practice-01 `
  --format="yaml(state,region,databaseVersion,settings.availabilityType,settings.ipConfiguration)"

gcloud compute forwarding-rules describe keycloak-postgres-psc `
  --region=us-central1 `
  --project=keycloak-practice-01
```

## Backup Strategy

Cloud SQL is configured for:

- Daily automated backup at `03:00` UTC.
- Seven retained automated backups.
- Seven days of transaction logs.
- Point-in-time recovery.
- Regional high availability.

List backups:

```powershell
gcloud sql backups list `
  --instance=keycloak-postgres `
  --project=keycloak-practice-01
```

Create an on-demand backup before a risky change:

```powershell
gcloud sql backups create `
  --instance=keycloak-postgres `
  --project=keycloak-practice-01 `
  --description="Before Keycloak upgrade"
```

Confirm that the new backup reaches `SUCCESSFUL` before continuing.

Backups protect database contents, not the complete platform configuration. Terraform, Helm values, GKE integration manifests and controlled Keycloak realm/client configuration must also be versioned.

## Restore Strategy

A restore is a high-impact operation. Prefer restoring or cloning into a separate recovery instance first. This preserves the source instance, allows validation and makes the recovery point explicit.

Recovery procedure:

1. Declare the incident and stop configuration changes.
2. Identify the last known good time and whether a backup restore or PITR is appropriate.
3. Create a separate recovery instance or clone at the chosen recovery point.
4. Validate database connectivity and Keycloak data against the recovery instance.
5. Schedule the cutover, update the PSC target/endpoint design as required and restart Keycloak in a controlled manner.
6. Validate login, realm data, OAuth and monitoring.
7. Retain the previous instance until the recovery is accepted.

Useful discovery commands:

```powershell
gcloud sql backups list --instance=keycloak-postgres --project=keycloak-practice-01
gcloud sql operations list --instance=keycloak-postgres --project=keycloak-practice-01
gcloud sql instances clone --help
gcloud sql backups restore --help
```

The exact restore command must be built from the selected backup ID, target instance and current `gcloud` syntax. Do not paste a production restore command from documentation without checking the target; restoring over the wrong instance is destructive.

## Keycloak Upgrade

Keycloak upgrades can include database migrations. Read both the Keycloak migration guide and the Helm chart release notes for every intermediate version.

Pre-upgrade checklist:

1. Confirm all three pods are ready and the current uptime check is healthy.
2. Confirm Cloud SQL health, free disk and recent successful backup.
3. Create an on-demand backup.
4. Review breaking changes and supported PostgreSQL/JDK combinations.
5. Update the pinned image/chart version in a branch.
6. Render and inspect the Helm change before deployment.

```powershell
helm template keycloak oci://ghcr.io/codecentric/helm-charts/keycloakx `
  --version 7.2.3 `
  --namespace keycloak `
  --values helm/keycloak/values.yaml > rendered-keycloak.yaml

helm diff upgrade keycloak oci://ghcr.io/codecentric/helm-charts/keycloakx `
  --version <target-chart-version> `
  --namespace keycloak `
  --values helm/keycloak/values.yaml
```

`helm diff` requires the Helm diff plugin. If it is unavailable, compare rendered manifests without committing the generated file.

Deploy with the repository script after updating the pinned versions:

```powershell
./scripts/deploy-keycloak.ps1
```

Observe rollout, logs and endpoint health:

```powershell
kubectl rollout status statefulset/keycloak-keycloakx -n keycloak --timeout=15m
kubectl get pods -n keycloak -w
kubectl logs -n keycloak statefulset/keycloak-keycloakx --since=15m
curl.exe -f https://keycloak.lab.getvitrina.gr/realms/master/.well-known/openid-configuration
```

## Helm Rollback

Inspect release history:

```powershell
helm history keycloak -n keycloak
```

Rollback to a known good revision:

```powershell
helm rollback keycloak <revision> -n keycloak --wait --timeout 15m
```

Validate all pods, the discovery endpoint and a real OAuth login afterward.

A Helm rollback restores Kubernetes configuration but does not reverse a Keycloak database migration. If the failed version changed the database incompatibly, use the tested database recovery plan and follow Keycloak's supported downgrade guidance. This is why pre-upgrade backups and release-note review are mandatory.

## Terraform Change Procedure

```powershell
terraform -chdir=terraform fmt -check -recursive
terraform -chdir=terraform validate
terraform -chdir=terraform plan `
  -var-file="environments/dev/terraform.tfvars" `
  -out="dev.plan"
terraform -chdir=terraform show "dev.plan"
terraform -chdir=terraform apply "dev.plan"
```

Review every create, update and destroy action. Do not apply a saved plan if its source configuration or credentials have changed. Do not store binary plans with `.tfvars` or `.tfplan` suffixes inside the source tree; use `.plan` and remove the file after the change.

## GKE Maintenance

The cluster uses the Regular release channel. Node pools have auto-upgrade, auto-repair, `max_surge = 1` and `max_unavailable = 0`. The PodDisruptionBudget protects two Keycloak replicas during voluntary disruption.

Before maintenance:

```powershell
kubectl get pdb -n keycloak
kubectl get pods -n keycloak -o wide
gcloud container clusters describe keycloak-gke `
  --region=us-central1 `
  --project=keycloak-practice-01 `
  --format="yaml(currentMasterVersion,releaseChannel,maintenancePolicy)"
```

During maintenance, monitor scheduling capacity. A PDB cannot protect against simultaneous involuntary failures, database unavailability or insufficient cluster capacity.

## Credential Rotation

The current database password is Terraform-generated and used by both Cloud SQL and a Kubernetes Secret. Rotating only one side causes an outage.

A controlled rotation must:

1. Generate and store the new value securely.
2. Update the Cloud SQL user password.
3. Update `keycloak-db-credentials` without printing the value.
4. Restart Keycloak pods in a controlled rollout.
5. Validate database connections and authentication.
6. Revoke the previous value and document the rotation.

The preferred production implementation uses Secret Manager and Workload Identity rather than Terraform outputs and local shell pipelines.

## Monitoring Tests

Uptime test:

```powershell
kubectl scale statefulset/keycloak-keycloakx -n keycloak --replicas=0
# Wait for incident and email.
kubectl scale statefulset/keycloak-keycloakx -n keycloak --replicas=3
kubectl rollout status statefulset/keycloak-keycloakx -n keycloak --timeout=10m
```

Failed-login test:

1. Submit 11 invalid usernames or passwords within one aligned 60-second interval.
2. Confirm 11 matching `LOGIN_ERROR` entries in Cloud Logging.
3. Confirm the `keycloak_failed_logins` incident and email.
4. Perform a successful login afterward.

Always restore service immediately after a deliberate outage test.
