terraform {
  required_version = "~> 1.3.1"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.40.0"
    }
  }
}

locals {
  defaultWebHostnames          = var.domain == null ? null : ["www.${var.domain}", "${var.domain}"]
  defaultApiHostnames          = var.domain == null ? null : ["api.${var.domain}"]
  defaultGrpcHostnames         = var.domain == null ? null : ["grpc.${var.domain}"]
  defaultEmbedFixtureHostnames = var.domain == null ? null : ["embed.${var.domain}"]

  webHostnames          = var.webHostnames == null ? local.defaultWebHostnames : var.webHostnames
  apiHostnames          = var.apiHostnames == null ? local.defaultApiHostnames : var.apiHostnames
  grpcHostnames         = var.grpcHostnames == null ? local.defaultGrpcHostnames : var.grpcHostnames
  embedFixtureHostnames = var.embedFixtureHostnames == null ? local.defaultEmbedFixtureHostnames : var.embedFixtureHostnames
}

module "speakeasy_k8s" {
  source                       = "../k8s"
  speakeasyName                = var.speakeasyName
  namespace                    = var.namespace
  webHostnames                 = local.webHostnames
  apiHostnames                 = local.apiHostnames
  grpcHostnames                = local.grpcHostnames
  embedFixtureHostnames        = local.embedFixtureHostnames
  createK8sPostgres            = var.createK8sPostgres
  postgresDSN                  = var.postgresDSN
  signInURL                    = var.signInURL
  githubClientId               = var.githubClientId
  githubClientSecretName       = var.githubClientSecretName
  githubClientSecretKey        = var.githubClientSecretKey
  githubClientSecretValue      = var.githubClientSecretValue
  githubCallbackURL            = var.githubCallbackURL
  serviceAccountSecretName     = var.serviceAccountSecretName
  serviceAccountSecretKey      = var.serviceAccountSecretKey
  serviceAccountSecretValue    = google_service_account_key.registry_service_account_key == null ? var.serviceAccountSecretValue : google_service_account_key.registry_service_account_key[0].private_key
  createServiceAccountSecret   = var.createServiceAccountSecret
  cloudProvider                = "gcp"
  ingressNginxEnabled          = var.ingressNginxEnabled
  controllerStaticIpOrHostname = var.controllerIp
}


