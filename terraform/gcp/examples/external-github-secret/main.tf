provider "google" {
  project = "speakeasy-project"
  zone    = "us-central1-c"
}

data "google_client_config" "provider" {}

data "google_container_cluster" "speakeasy_gke_cluster" {
  name = "terraform-cluster-test"
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.speakeasy_gke_cluster.endpoint}"
  token                  = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.speakeasy_gke_cluster.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${data.google_container_cluster.speakeasy_gke_cluster.endpoint}"
    token                  = data.google_client_config.provider.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.speakeasy_gke_cluster.master_auth[0].cluster_ca_certificate)
  }
}

module "gcp_speakeasy" {
  source        = "../../"
  speakeasyName = "speakeasy-tf-gcp"
  # we want the module to create a zone on Cloud DNS + its corresponding A records
  # so we need to pass in a domain.
  domain                 = "speakeasyplatform.com"
  createK8sPostgres      = true # do not set to true in production, setting to `true` in this example for simplicity
  signInURL              = "https://speakeasyplatform.com"
  githubClientId         = "CLIENT_ID"
  githubClientSecretName = "github-client-secret"
  githubClientSecretKey  = "githubClientSecret"
  githubCallbackURL      = "https://speakeasyplatform.com/v1/auth/callback/github"
  ingressNginxEnabled    = true
}
