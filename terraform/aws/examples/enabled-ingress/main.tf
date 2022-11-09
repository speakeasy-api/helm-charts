provider "aws" {
  region = "us-east-1"
}

locals {
  kubernetesCluster = "speakeasy-cluster"
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
  source        = "../../"
  speakeasyName = "speakeasy-tf-aws"
  # we want the module to create a zone on Route 53 + its corresponding A records
  # so we need to pass in a domain.
  domain                  = "speakeasyplatform.com"
  createK8sPostgres       = true # do not set to true in production, setting to `true` in this example for simplicity
  signInURL               = "https://speakeasyplatform.com"
  githubClientId          = "CLIENT_ID"
  githubClientSecretValue = "CLIENT_SECRET"
  githubCallbackURL       = "https://speakeasyplatform.com/v1/auth/callback/github"
  ingressNginxEnabled     = true
}
