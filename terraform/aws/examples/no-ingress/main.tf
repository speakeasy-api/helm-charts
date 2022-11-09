provider "aws" {
  region = "us-east-1"
}

locals {
  kubernetesCluster = "jose-test"
  #kubernetesCluster = "speakeasy-cluster"
}

data "aws_eks_cluster" "speakeasy_eks_cluster" {
  name = local.kubernetesCluster
}

data "aws_eks_cluster_auth" "speakeasy_eks_cluster" {
  name = local.kubernetesCluster
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.speakeasy_eks_cluster.endpoint
  token                  = data.aws_eks_cluster_auth.speakeasy_eks_cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.speakeasy_eks_cluster.certificate_authority.0.data)
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.speakeasy_eks_cluster.endpoint
    token                  = data.aws_eks_cluster_auth.speakeasy_eks_cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.speakeasy_eks_cluster.certificate_authority.0.data)
  }
}

module "aws_speakeasy" {
  source            = "../../"
  speakeasyName     = "speakeasy-tf-aws"
  createK8sPostgres = true # do not set to true in production, setting to `true` in this example for simplicity
  #there's currently no way to disable auth so we still need to set the oauth config
  signInURL               = "http://localhost:3000"
  githubClientId          = "CLIENT_ID"
  githubClientSecretValue = "CLIENT_SECRET"
  githubCallbackURL       = "http://localhost:8080/v1/auth/callback/github"
  ingressNginxEnabled     = false # we are going to connect to speakeasy via `kubectl port-forward`
}
