resource "helm_release" "postgres_k8s" {
  name       = "postgresql"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "11.9.5"
  namespace  = var.namespace
  count      = var.createK8sPostgres ? 1 : 0

  set {
    name  = "auth.postgresPassword"
    value = "postgres"
  }

  set {
    name  = "volumePermissions.enabled"
    value = "true"
  }

  set {
    name  = "primary.service.type"
    value = "LoadBalancer"
  }
}

data "kubernetes_service" "postgres" {
  metadata {
    name = "postgresql"
  }

  depends_on = [
    helm_release.postgres_k8s
  ]
}

locals {
  postgresIpOrHostname = length(data.kubernetes_service.postgres.status.0.load_balancer.0.ingress.0.ip) == 0 ? data.kubernetes_service.postgres.status.0.load_balancer.0.ingress.0.hostname : data.kubernetes_service.postgres.status.0.load_balancer.0.ingress.0.ip
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.6.1"
  count      = var.ingressNginxEnabled ? 1 : 0

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "podDnsPolicy"
    value = "None"
  }

  set {
    name  = "podDnsConfig.nameservers"
    value = "{8.8.8.8,1.1.1.1,208.67.222.222}"
  }
}

locals {
  ingressNginxFullName     = "${var.speakeasyName}-ingress-nginx"
  controllerSuffix         = "controller"
  controllerFullName       = "${local.ingressNginxFullName}-${local.controllerSuffix}"
  ingressNginxIpOrHostname = length(data.kubernetes_service.ingress_nginx) == 0 ? null : (length(data.kubernetes_service.ingress_nginx.0.status.0.load_balancer.0.ingress.0.ip) == 0 ? data.kubernetes_service.ingress_nginx.0.status.0.load_balancer.0.ingress.0.hostname : data.kubernetes_service.ingress_nginx.0.status.0.load_balancer.0.ingress.0.ip)
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.0.13"
  count      = var.ingressNginxEnabled ? 1 : 0

  set {
    name  = "controller.config.use-forwarded-headers"
    value = "true"
  }

  set {
    name  = "controller.config.use-http2"
    value = "true"
  }

  set {
    name  = "controller.name"
    value = local.controllerSuffix
  }

  set {
    name  = "fullnameOverride"
    value = local.ingressNginxFullName
  }

  set {
    name  = "controller.service.loadBalancerIP"
    value = var.controllerStaticIpOrHostname == null ? "" : var.controllerStaticIpOrHostname
  }
}

data "kubernetes_service" "ingress_nginx" {
  metadata {
    name = local.controllerFullName
  }

  depends_on = [helm_release.ingress_nginx]
  count      = var.ingressNginxEnabled ? 1 : 0
}


locals {
  defaultGithubClientSecretKey  = var.githubClientSecretValue == null ? "" : "githubClientSecret"
  defaultGithubClientSecretName = var.githubClientSecretValue == null ? "" : "github-client-secret"

  defaultServiceAccountSecretKey  = var.createServiceAccountSecret ? "service_account.json" : ""
  defaultServiceAccountSecretName = var.createServiceAccountSecret ? "speakeasy-service-account-credentials" : ""

  finalServiceAccountSecretKey  = var.serviceAccountSecretKey == null ? local.defaultServiceAccountSecretKey : var.serviceAccountSecretKey
  finalServiceAccountSecretName = var.serviceAccountSecretName == null ? local.defaultServiceAccountSecretName : var.serviceAccountSecretName
}

resource "helm_release" "speakeasy" {
  name       = "speakeasy"
  chart      = "speakeasy-k8s"
  repository = "https://speakeasy-api.github.io/helm-charts"
  namespace  = var.namespace
  version    = "3.0.0"

  set {
    name  = "fullnameOverride"
    value = var.speakeasyName
  }

  set {
    name  = "postgresql.DSN"
    value = var.createK8sPostgres ? "postgres://postgres:postgres@${local.postgresIpOrHostname}:5432/postgres?sslmode=disable" : var.postgresDSN
  }

  set {
    name  = "registry.ingress.enabled"
    value = var.ingressNginxEnabled ? "true" : "false"
  }

  set {
    name  = "createClusterIssuer"
    value = var.ingressNginxEnabled ? "true" : "false"
  }

  set {
    name  = "ingress-nginx.enabled"
    value = "false"
  }

  set {
    name  = "postgresql.enabled"
    value = "false"
  }

  set {
    name  = "portal.enabled"
    value = "false"
  }

  set {
    name  = "auth.SignInURL"
    value = var.signInURL == null ? "" : var.signInURL
  }

  set {
    name  = "auth.GithubClientId"
    value = var.githubClientId == null ? "" : var.githubClientId
  }

  set {
    name  = "auth.GithubCallbackURL"
    value = var.githubCallbackURL
  }

  set {
    name  = "auth.GithubClientSecret"
    value = var.githubClientSecretValue == null ? "" : var.githubClientSecretValue
  }

  set {
    name  = "auth.GithubClientSecretName"
    value = var.githubClientSecretName == null ? local.defaultGithubClientSecretName : var.githubClientSecretName
  }

  set {
    name  = "auth.GithubClientSecretKey"
    value = var.githubClientSecretKey == null ? local.defaultGithubClientSecretKey : var.githubClientSecretKey
  }

  set {
    name  = "registry.svcSecretName"
    value = local.finalServiceAccountSecretName
  }

  set {
    name  = "registry.svcSecretKey"
    value = local.finalServiceAccountSecretKey
  }

  set {
    name  = "cloud"
    value = var.cloudProvider
  }

  set {
    name  = "registry.ingress.apiHostnames"
    value = var.apiHostnames == null ? "" : "{${join(",", var.apiHostnames)}}"
  }

  set {
    name  = "registry.ingress.webHostnames"
    value = var.webHostnames == null ? "" : "{${join(",", var.webHostnames)}}"
  }

  set {
    name  = "registry.ingress.grpcHostnames"
    value = var.grpcHostnames == null ? "" : "{${join(",", var.grpcHostnames)}}"
  }

  set {
    name  = "registry.ingress.embedFixtureHostnames"
    value = var.embedFixtureHostnames == null ? "" : "{${join(",", var.embedFixtureHostnames)}}"
  }

  depends_on = [
    helm_release.ingress_nginx, helm_release.cert_manager, kubernetes_secret.registry_service_account_secret
  ]
}
