# Speakeasy AWS Terraform Module

Terraform module that installs Speakeasy on a Kubernetes cluster running on AWS. The main goal of this module is to support moving towards a single-action install of Speakeasy in the self-hosted scenario.

Depending on the variables you set, this module will do all or some of the following actions:

- Install speakeasy container(s) in the given kubernetes cluster
- Install postgresql in the given kubernetes cluster
- Install cert-manager in the given kubernetes cluster
- Instanll nginx in the given kubernetes cluster
- Create necessary service accounts needed to run on GCP
- Create `Route 53` Zone for a given domain + its corresponding A records.

## Instructions

Even though we'd like this module to be a single-action install of Speakeasy, it isn't quite there yet. There are still things we need to do before and after installing the module. Go through the following steps to get speakeasy up and running using the module:

1. **Register a domain**: domain that will point to your speakeasy instance. For this you can use `Route 53` or any other domain registrar. Worth noting that this step is not 100% necessary: you can still get speakeasy working without registering a domain using `kubectl portforward` (more information [here](./examples/no-ingress/README.md)).
1. **Set up OAuth on Github**: Speakeasy uses Github OAuth to provide authentication for your org. Under settings for the Github Organization you'd like to authenticate (or your personal profile) , click `Developer Settings" > Oauth Apps > New Oauth App`. Fill in the fields as follows:

   - Homepage URL: `https://<var.domain>`
   - Authorization callback URL: `https://<var.domain>/v1/auth/callback/github`

   replacing `<var.domain>` with the same value you are setting in the module's `domain` variable.

1. **Install terraform module**: you'll need to have the following providers:

   - kubernetes provider pointing to the kubernetes cluster where you'd like speakeasy to be installed
   - helm provider pointing to the kubernetes cluster where you'd like speakeasy to be installed
   - aws provider pointing to the region where the kubernetes cluster where speakeasy will be installed lives

   Once you have the above then you are good to make use of the module and install speakeasy running `terraform apply`.

1. **Update name servers**: If the module created a domain zone for you then most likely you'll need to update the domain's name servers to point to the ones in the newly created zone.

Your speakeasy instance might not be available right away - you might have to wait a few minutes for the DNS changes to propagate.

## Module Usage Example

```
provider "aws" {
  region = "us-west-1"
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
  source                  = "./"
  speakeasyName           = "my-speakeasy"
  domain                  = "speakeasyplatform.com"
  createK8sPostgres       = true
  signInURL               = "https://speakeasyplatform.com"
  githubClientId          = "<CLIENT_ID>"
  githubClientSecretValue = "<CLIENT_SECRET>"
  githubCallbackURL       = "https://speakeasyplatform.com/v1/auth/callback/github"
  ingressNginxEnabled     = true
}

```

## Requirements

| Name                                                                     | Version   |
| ------------------------------------------------------------------------ | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.3.1  |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | >= 4.34.0 |

## Providers

| Name                                             | Version   |
| ------------------------------------------------ | --------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | >= 4.34.0 |

## Modules

| Name                                                                       | Source | Version |
| -------------------------------------------------------------------------- | ------ | ------- |
| <a name="module_speakeasy_k8s"></a> [speakeasy_k8s](#module_speakeasy_k8s) | ../k8s | n/a     |

## Resources

| Name                                                                                                                              | Type        |
| --------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_route53_record.api_dns_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)   | resource    |
| [aws_route53_record.embed_dns_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource    |
| [aws_route53_record.grpc_dns_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)  | resource    |
| [aws_route53_record.web_dns_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)   | resource    |
| [aws_route53_zone.speakeasy_dns_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone)   | resource    |
| [aws_elb_hosted_zone_id.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/elb_hosted_zone_id)  | data source |

## Inputs

| Name                                                                                                   | Description                                                                                                                                                                                                                                                                                                                                                                                                | Type           | Default       |
| ------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------------- |
| <a name="input_apiHostnames"></a> [apiHostnames](#input_apiHostnames)                                  | List of domain names for registry api. Setting this var only makes sense if `ingressNginxEnabled` is set to true. If `ingressNginxEnabled` is set to true and `domain` is not set then this variable can't be null. If `ingressNginxEnabled` is set to true and `domain` is set as well then the modules will set the hostnames for you (api.<DOMAIN> will be the api hostname)                            | `list(string)` | `null`        |
| <a name="input_controllerHostname"></a> [controllerHostname](#input_controllerHostname)                | static public hostname to be used on nginx's controller. If null then AWS will assign a hostname for you.                                                                                                                                                                                                                                                                                                  | `string`       | `null`        |
| <a name="input_createK8sPostgres"></a> [createK8sPostgres](#input_createK8sPostgres)                   | If true, a postgresql database will be installed on EKS alongside speakeasy. This is not recommended for production, you should think of this database as a non persistent database                                                                                                                                                                                                                        | `bool`         | `false`       |
| <a name="input_domain"></a> [domain](#input_domain)                                                    | Domain that will point to your speakeasy instance (e.g. `speakeasyplatform.com`. If set this value will be used to create a zone on Route 53. Do not set if you don't need this module to create a Route 53 zone.                                                                                                                                                                                          | `string`       | `null`        |
| <a name="input_embedFixtureHostnames"></a> [embedFixtureHostnames](#input_embedFixtureHostnames)       | List of domain names for registry embed-fixture UI. Setting this var only makes sense if `ingressNginxEnabled` is set to true. If `ingressNginxEnabled` is set to true and `domain` is not set then this variable can't be null. If `ingressNginxEnabled` is set to true and `domain` is set as well then the modules will set the hostnames for you (embed.<DOMAIN> will be the embed hostname)           | `list(string)` | `null`        |
| <a name="input_githubCallbackURL"></a> [githubCallbackURL](#input_githubCallbackURL)                   | Your application’s callback URL (e.g. `https://api.selfhostspeakeasy.com/v1/auth/callback/github`)                                                                                                                                                                                                                                                                                                         | `string`       | `null`        |
| <a name="input_githubClientId"></a> [githubClientId](#input_githubClientId)                            | Client ID of the Github Oauth app.                                                                                                                                                                                                                                                                                                                                                                         | `string`       | `null`        |
| <a name="input_githubClientSecretKey"></a> [githubClientSecretKey](#input_githubClientSecretKey)       | Kubernetes secret key in `githubClientSecretName` that maps to the github client secret. Setting this value only makes sense when `githubClientSecretValue` is null (a kubernetes secret already exists contining the github secret)                                                                                                                                                                       | `string`       | `null`        |
| <a name="input_githubClientSecretName"></a> [githubClientSecretName](#input_githubClientSecretName)    | Kubernetes secret name containing github client secret. Setting this value only makes sense when `githubClientSecretValue` is null (a kubernetes secret already exists contining the github secret)                                                                                                                                                                                                        | `string`       | `null`        |
| <a name="input_githubClientSecretValue"></a> [githubClientSecretValue](#input_githubClientSecretValue) | Client secret of the Github Oauth app. If not null then a kubernetes secret will be created containing this value.                                                                                                                                                                                                                                                                                         | `string`       | `null`        |
| <a name="input_grpcHostnames"></a> [grpcHostnames](#input_grpcHostnames)                               | List of domain names for gRPC service used for request capture. Setting this var only makes sense if `ingressNginxEnabled` is set to true. If `ingressNginxEnabled` is set to true and `domain` is not set then this variable can't be null. If `ingressNginxEnabled` is set to true and `domain` is set as well then the modules will set the hostnames for you (grpc.<DOMAIN> will be the grpc hostname) | `list(string)` | `null`        |
| <a name="input_ingressNginxEnabled"></a> [ingressNginxEnabled](#input_ingressNginxEnabled)             | Whether or not ingress is enabled via nginx                                                                                                                                                                                                                                                                                                                                                                | `bool`         | `false`       |
| <a name="input_namespace"></a> [namespace](#input_namespace)                                           | Kubernetes namespace where speakeasy will be installed                                                                                                                                                                                                                                                                                                                                                     | `string`       | `"default"`   |
| <a name="input_postgresDSN"></a> [postgresDSN](#input_postgresDSN)                                     | Connection string for a particular data source to store Speakeasy-maintained config and requests. Must be set if createK8sPostgres is false                                                                                                                                                                                                                                                                | `string`       | `null`        |
| <a name="input_privateZoneVpcId"></a> [privateZoneVpcId](#input_privateZoneVpcId)                      | A private DNS zone contains DNS records that are only visible internally within your AWS network(s). A public zone is visible to the internet. This variable specifies the VPC associated with the speakeasy's PRIVATE zone. If null, a public zone will be used.                                                                                                                                          | `string`       | `null`        |
| <a name="input_signInURL"></a> [signInURL](#input_signInURL)                                           | The full URL to the Speakeasy homepage the user will be redirected to upon signing in (e.g. `https://www.selfhostspeakeasy.com`)                                                                                                                                                                                                                                                                           | `string`       | `null`        |
| <a name="input_speakeasyName"></a> [speakeasyName](#input_speakeasyName)                               | Prefix of most resources names                                                                                                                                                                                                                                                                                                                                                                             | `string`       | `"speakeasy"` |
| <a name="input_webHostnames"></a> [webHostnames](#input_webHostnames)                                  | List of domain names for registry web UI. Setting this var only makes sense if `ingressNginxEnabled` is set to true. If `ingressNginxEnabled` is set to true and `domain` is not set then this variable can't be null. If `ingressNginxEnabled` is set to true and `domain` is set as well then the modules will set the hostnames for you (www.<DOMAIN> and <DOMAIN> will be the web hostnames)           | `list(string)` | `null`        |

## Outputs

No outputs.
