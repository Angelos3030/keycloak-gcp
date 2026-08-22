$ErrorActionPreference = "Stop"

$namespace = "keycloak"
$expectedContext = "gke_keycloak-practice-01_us-central1_keycloak-gke"

$currentContext = kubectl config current-context

if ($currentContext -ne $expectedContext) {
    throw "Wrong cluster: $currentContext"
}

$pscIp = terraform -chdir=terraform `
    output -raw cloudsql_psc_endpoint_ip

$dbPassword = terraform -chdir=terraform `
    output -raw cloudsql_database_user_password

kubectl create namespace $namespace `
    --dry-run=client `
    --output=yaml |
    kubectl apply -f -

kubectl create secret generic keycloak-db-credentials `
    --namespace $namespace `
    --from-literal="password=$dbPassword" `
    --dry-run=client `
    --output=yaml |
    kubectl apply -f -

$adminSecret = kubectl get secret keycloak-admin-credentials `
    --namespace $namespace `
    --ignore-not-found `
    --output=name

if ([string]::IsNullOrWhiteSpace($adminSecret)) {
    $randomBytes = [Security.Cryptography.RandomNumberGenerator]::GetBytes(24)
    $adminPassword = [Convert]::ToBase64String($randomBytes)

    kubectl create secret generic keycloak-admin-credentials `
        --namespace $namespace `
        --from-literal="password=$adminPassword"
}

helm upgrade --install keycloak `
    oci://ghcr.io/codecentric/helm-charts/keycloakx `
    --version 7.2.3 `
    --namespace $namespace `
    --values helm/keycloak/values.yaml `
    --set-string "database.hostname=$pscIp" `
    --wait `
    --timeout 15m