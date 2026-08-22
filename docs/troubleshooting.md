# Troubleshooting Guide

## Diagnostic Order

Troubleshoot from the outside inward:

```text
DNS -> certificate/load balancer -> Ingress/backend health -> Service/NEG
-> Keycloak pod health -> PSC routing -> Cloud SQL -> application configuration
```

This order avoids changing Keycloak when the failure is actually DNS or load-balancer provisioning.

## Authentication and Context

Confirm GCP identity, project and Kubernetes context:

```powershell
gcloud auth list
gcloud config get-value project
kubectl config current-context
```

Refresh Terraform Application Default Credentials after `invalid_grant` or `invalid_rapt`:

```powershell
gcloud auth application-default login
```

Refresh GKE credentials:

```powershell
gcloud container clusters get-credentials keycloak-gke `
  --region=us-central1 `
  --project=keycloak-practice-01
```

Never apply Terraform or run the deployment script against an unexpected account, project or Kubernetes context.

## Terraform Reports Invalid Characters

Symptom:

```text
Error: Invalid character
on dev.tfvars or dev.tfplan
```

Cause: a binary saved plan was named with a Terraform source suffix, so `terraform fmt -recursive` attempted to parse it.

Find suspicious files:

```powershell
Get-ChildItem terraform -File | Where-Object Name -Match 'tfplan|tfvars|plan'
```

The real variables file is `terraform/environments/dev/terraform.tfvars`. Saved plans should use a `.plan` suffix and should not be committed.

After removing only confirmed binary plan files:

```powershell
terraform -chdir=terraform fmt -recursive
terraform -chdir=terraform validate
```

## Terraform Authentication Fails

Symptom:

```text
oauth2: invalid_grant
reauth related error (invalid_rapt)
```

Fix:

```powershell
gcloud auth application-default login
gcloud auth application-default print-access-token | Out-Null
```

Also inspect whether `GOOGLE_APPLICATION_CREDENTIALS` points Terraform at an unexpected credential file:

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS
```

## Helm Release Is Pending

Inspect status and history:

```powershell
helm status keycloak -n keycloak
helm history keycloak -n keycloak
kubectl get pods -n keycloak
kubectl get events -n keycloak --sort-by=.lastTimestamp
```

A command interrupted during `helm upgrade --wait` can leave the release in `pending-upgrade`. Diagnose the pods first. If the new revision is not usable, rollback to a known good revision:

```powershell
helm rollback keycloak <revision> -n keycloak --wait --timeout 15m
```

Do not uninstall as the first response; uninstalling removes release-managed resources and makes diagnosis harder.

## Keycloak Pod Is Not Ready

```powershell
kubectl get pods -n keycloak -o wide
kubectl describe pod <pod-name> -n keycloak
kubectl logs <pod-name> -n keycloak -c keycloak --since=15m
kubectl logs <pod-name> -n keycloak -c dbchecker
```

Common causes:

- PSC endpoint or database is unreachable.
- Database credentials do not match Cloud SQL.
- Keycloak hostname/proxy configuration is invalid.
- Resource requests cannot be scheduled.
- Database migration is still running or failed.

Do not print Kubernetes Secret values into shared terminals or tickets.

## Database Connectivity Fails

Confirm configured endpoint and resources:

```powershell
terraform -chdir=terraform output cloudsql_psc_endpoint_ip
gcloud compute forwarding-rules describe keycloak-postgres-psc `
  --region=us-central1 `
  --project=keycloak-practice-01
gcloud sql instances describe keycloak-postgres `
  --project=keycloak-practice-01
```

Confirm Keycloak uses the same PSC IP:

```powershell
helm get values keycloak -n keycloak
```

From an ephemeral diagnostic pod, test only TCP reachability:

```powershell
kubectl run psc-check -n keycloak --rm -it --restart=Never `
  --image=nicolaka/netshoot -- nc -vz 10.11.0.2 5432
```

If TCP fails, inspect the PSC forwarding rule, subnet, VPC and Cloud SQL allowed consumer project. If TCP succeeds but Keycloak authentication fails, investigate the database name, user and synchronized secret.

## Ingress Has an Address but Returns Errors

```powershell
kubectl describe ingress keycloak-keycloakx -n keycloak
kubectl get service,endpoints,endpointslice -n keycloak
kubectl describe backendconfig keycloak-backend-config -n keycloak
gcloud compute backend-services list --global --project=keycloak-practice-01
```

An `UNHEALTHY` backend commonly means the load balancer is checking the wrong path or port. This deployment expects:

```text
Path: /health/ready
Port: 9000
Protocol: HTTP
```

The GKE-generated firewall rule must allow Google health-check ranges to the relevant backend ports. Do not open those ports to the entire internet.

## DNS Does Not Resolve

```powershell
Resolve-DnsName -Type NS lab.getvitrina.gr
Resolve-DnsName keycloak.lab.getvitrina.gr
gcloud dns managed-zones describe keycloak-lab --project=keycloak-practice-01
gcloud dns record-sets list --zone=keycloak-lab --project=keycloak-practice-01
```

The parent zone must delegate `lab.getvitrina.gr` to all Cloud DNS nameservers assigned to the managed zone. The Keycloak A record must match the reserved global address.

## Managed Certificate Stays Provisioning

```powershell
kubectl describe managedcertificate keycloak-certificate -n keycloak
kubectl describe ingress keycloak-keycloakx -n keycloak
Resolve-DnsName keycloak.lab.getvitrina.gr
gcloud compute addresses describe keycloak-public-ip `
  --global `
  --project=keycloak-practice-01
```

Provisioning requires public DNS to resolve to the load balancer and the Ingress to reference the certificate. Certificate issuance can take time after DNS changes. Cloudflare proxying should not obscure validation during initial provisioning; delegated Cloud DNS should answer authoritatively.

## HTTP Works but HTTPS Does Not

```powershell
curl.exe -vk https://keycloak.lab.getvitrina.gr
kubectl get managedcertificate keycloak-certificate -n keycloak
kubectl describe ingress keycloak-keycloakx -n keycloak
```

Confirm the certificate is `Active` and the HTTPS forwarding rule exists. `curl -k` is diagnostic only; successful production validation must work without bypassing trust.

## OAuth Client Not Found

Symptom:

```text
Client not found
```

Inspect the authorization URL. `client_id` must be the Keycloak Client ID, not the username:

```text
Realm: demo
Client ID: keycloak-app
Username: test
```

The OAuth client must exist in the same realm as the user. Valid redirects are restricted to `https://www.keycloak.org/app/*`, and the web origin is `https://www.keycloak.org`.

## Uptime Alert Fires While Service Is Healthy

Check endpoint health and active policy configuration:

```powershell
curl.exe -f https://keycloak.lab.getvitrina.gr/realms/master/.well-known/openid-configuration
gcloud monitoring policies list --project=keycloak-practice-01
```

The boolean uptime metric must use `ALIGN_FRACTION_TRUE`, not `ALIGN_RATE`. Forecasting is inappropriate for this boolean availability signal; use a threshold condition. Old incidents can continue to reference the previous condition name until they close.

## Failed-Login Alert Does Not Fire

Verify Keycloak emits matching events:

```bash
for pod in $(kubectl get pods -n keycloak -l app.kubernetes.io/name=keycloakx -o name); do
  kubectl logs -n keycloak "$pod" --since=5m |
    grep -Ei 'LOGIN_ERROR|invalid_user_credentials'
done
```

Verify the log metric and alert policy:

```powershell
gcloud logging metrics describe keycloak_failed_logins --project=keycloak-practice-01
gcloud monitoring policies list --project=keycloak-practice-01
```

The metric does not backfill logs created before the metric existed. Generate 11 matching failures inside one aligned 60-second interval, then allow time for log ingestion and alert evaluation. Ensure the alert uses `ALIGN_SUM`, `REDUCE_SUM`, `COMPARISON_GT` and threshold `10`.

## Escalation Evidence

Capture these without credentials:

- UTC start/end time and observed impact.
- `kubectl get pods -o wide`, events and relevant sanitized logs.
- Helm revision and deployed image version.
- Ingress/backend health and certificate status.
- Cloud SQL operation status and PSC forwarding-rule state.
- Monitoring incident link and condition details.
- Recent Terraform/Helm change identifier.

Avoid screenshots or output containing passwords, tokens, cookies or full Secret objects.
