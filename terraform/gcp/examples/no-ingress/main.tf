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
  source                  = "../../"
  speakeasyName           = "speakeasy-tf-gcp"
  createK8sPostgres       = true # do not set to true in production, setting to `true` in this example for simplicity
  signInURL               = "http://localhost:35291"
  githubClientId          = "CLIENT_ID"
  githubClientSecretValue = "CLIENT_SECRET"
  githubCallbackURL       = "http://localhost:35290/v1/auth/callback/github"
  ingressNginxEnabled     = false
}
