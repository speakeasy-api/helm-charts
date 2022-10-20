resource "google_service_account" "speakeasy_container_service_account" {
  account_id   = "speakasy-container-sa"
  display_name = "Service Account for speakeasy container"
  count        = var.createServiceAccount ? 1 : 0
}

data "google_service_account" "speakeasy_container_service_account" {
  account_id = var.serviceAccountId
  count      = var.serviceAccountId == null ? 0 : 1
}

resource "google_service_account_key" "registry_service_account_key" {
  service_account_id = var.createServiceAccount ? google_service_account.speakeasy_container_service_account[0].account_id : data.google_service_account.speakeasy_container_service_account[0].account_id
  public_key_type    = "TYPE_X509_PEM_FILE"
  count              = var.serviceAccountId != null || var.createServiceAccount ? 1 : 0
}
