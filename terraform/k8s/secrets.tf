resource "kubernetes_secret" "registry_service_account_secret" {
  metadata {
    name      = var.createServiceAccountSecret ? local.finalServiceAccountSecretName : "secret-name-placeholder"
    namespace = var.namespace
  }

  data = {
    (var.createServiceAccountSecret ? local.finalServiceAccountSecretKey : "key_placeholder") = base64decode(var.serviceAccountSecretValue)
  }

  count = var.createServiceAccountSecret ? 1 : 0
}
