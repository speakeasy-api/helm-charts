# Speakeasy GCP Terraform Module

Terraform module that installs Speakeasy on a Kubernetes cluster running on GCP. The main goal of this module is to support moving towards a single-action install of Speakeasy in the self-hosted scenario.

Depending on the variables you set, this module will do all or some of the following actions:

- Install speakeasy container(s) in the given kubernetes cluster
- Install postgresql in the given kubernetes cluster
- Install cert-manager in the given kubernetes cluster
- Instanll nginx in the given kubernetes cluster
- Create `Cloud DNS` Zone for a given domain + its corresponding A records.

## Instructions

Even though we'd like this module to be a single-action install of Speakeasy, it isn't quite there yet. There are still things we need to do before and after installing the module. Go through the following steps to get speakeasy up and running using the module:

1. **Register a domain**: domain that will point to your speakeasy instance. For this you can use `Cloud DNS` or any other domain registrar. The domain you register should be the value you set on the `domain` variable of the module. Worth noting that this step is not 100% necessary: you can still get speakeasy working without registering a domain using `kubectl portforward` (more information [here](./examples/no-ingress/README.md)).
1. **Set up OAuth on Github**: Speakeasy uses Github OAuth to provide authentication for your org. Under settings for the Github Organization you'd like to authenticate (or your personal profile) , click `Developer Settings" > Oauth Apps > New Oauth App`. Fill in the fields as follows:

   - Homepage URL: `https://<domain>`
   - Authorization callback URL: `https://<domain>/v1/auth/callback/github`

   replacing `<domain>` with the same value you are setting in the module's `domain` variable.

1. **Get Client ID and Client Secret**: After registering your application in the previous step you'll be redirected to a configuration view of the application you just registered. The value under `Client ID` should be the value you set on the module's `githubClientId` variable. Similarly, under `Client secrets` you'll click on `Generate a new client secret` and the provided secret should be the value you set on the module's `githubClientSecretValue`.
1. **Install terraform module**: you'll need to have the following providers:

   - kubernetes provider pointing to the kubernetes cluster where you'd like speakeasy to be installed
   - helm provider pointing to the kubernetes cluster where you'd like speakeasy to be installed
   - google provider pointing to the project where you'd like speakeasy to be installed

   Once you have the above then you are good to make use of the module and install speakeasy running `terraform init && terraform apply`.

1. **Update name servers**: If the module created a domain zone for you then most likely you'll need to update the domain's name servers to point to the ones in the newly created zone. To get the name servers used by the domain zone you can run `gcloud dns managed-zones describe <ZONE-NAME>` where `<ZONE-NAME>` is the value you set on the `domain` variable in the module, but replacing `.` with `-` (`my.domain.com` -> `my-domain-com`).

Done! Your speakeasy instance might not be available right away - you might have to wait a few minutes for the DNS changes to propagate.

## Module Usage Example

```
provider "google" {
  project = "speakeasy-project"
  zone    = "us-central1-c"
}

data "google_client_config" "provider" {}

data "google_container_cluster" "speakeasy_gke_cluster" {
  name = "speakeasy-cluster"
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

More detailed examples in [examples](./examples/).

## Requirements

| Name                                                                     | Version   |
| ------------------------------------------------------------------------ | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.3.1  |
| <a name="requirement_google"></a> [google](#requirement_google)          | >= 4.40.0 |

## Providers

| Name                                                      | Version   |
| --------------------------------------------------------- | --------- |
| <a name="provider_google"></a> [google](#provider_google) | >= 4.40.0 |

## Modules

| Name                                                                       | Source | Version |
| -------------------------------------------------------------------------- | ------ | ------- |
| <a name="module_speakeasy_k8s"></a> [speakeasy_k8s](#module_speakeasy_k8s) | ../k8s | n/a     |

## Resources

| Name                                                                                                                                                            | Type        |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [google_dns_managed_zone.speakeasy_dns_zone](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone)                   | resource    |
| [google_dns_record_set.api_dns_record](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set)                           | resource    |
| [google_dns_record_set.embed_dns_record](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set)                         | resource    |
| [google_dns_record_set.grpc_dns_record](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set)                          | resource    |
| [google_dns_record_set.web_dns_record](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set)                           | resource    |
| [google_service_account.speakeasy_container_service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account)    | resource    |
| [google_service_account_key.registry_service_account_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key)   | resource    |
| [google_service_account.speakeasy_container_service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/service_account) | data source |

## Inputs

| Name                                                                                                            | Description                                                                                                                                                                                                                                                                                                                                                                                                | Type           | Default       |
| --------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------------- |
| <a name="input_apiHostnames"></a> [apiHostnames](#input_apiHostnames)                                           | List of domain names for registry api. Setting this var only makes sense if `ingressNginxEnabled` is set to true. If `ingressNginxEnabled` is set to true and `domain` is not set then this variable can't be null. If `ingressNginxEnabled` is set to true and `domain` is set as well then the modules will set the hostnames for you (api.<DOMAIN> will be the api hostname)                            | `list(string)` | `null`        |
| <a name="input_controllerIp"></a> [controllerIp](#input_controllerIp)                                           | static public IP to be used on nginx's controller. If null then GCP will assign an IP for you.                                                                                                                                                                                                                                                                                                             | `string`       | `null`        |
| <a name="input_createK8sPostgres"></a> [createK8sPostgres](#input_createK8sPostgres)                            | If true, a postgresql database will be installed on GKE alongside speakeasy. This is not recommended for production, you should think of this database as a non persistent database                                                                                                                                                                                                                        | `bool`         | `false`       |
| <a name="input_createServiceAccount"></a> [createServiceAccount](#input_createServiceAccount)                   | If true creates a new service account for which a private key will be created and used by speakeasy to authenticate with GCP. This private key will be used instead of the value set in `serviceAccountSecretValue`.                                                                                                                                                                                       | `bool`         | `true`        |
| <a name="input_createServiceAccountSecret"></a> [createServiceAccountSecret](#input_createServiceAccountSecret) | If true a kubernetes secret will be created containing the the private key used by speakeasy to authenticate with GCP.                                                                                                                                                                                                                                                                                     | `bool`         | `true`        |
| <a name="input_domain"></a> [domain](#input_domain)                                                             | Domain that will point to your speakeasy instance (e.g. `speakeasyplatform.com`. If set this value will be used to create a zone on cloud dns. Do not set if you don't need this module to create a cloud dns zone.                                                                                                                                                                                        | `string`       | `null`        |
| <a name="input_domainZoneVisibility"></a> [domainZoneVisibility](#input_domainZoneVisibility)                   | A private DNS zone contains DNS records that are only visible internally within your Google Cloud network(s). A public zone is visible to the internet.                                                                                                                                                                                                                                                    | `string`       | `"public"`    |
| <a name="input_embedFixtureHostnames"></a> [embedFixtureHostnames](#input_embedFixtureHostnames)                | List of domain names for registry embed-fixture UI. Setting this var only makes sense if `ingressNginxEnabled` is set to true. If `ingressNginxEnabled` is set to true and `domain` is not set then this variable can't be null. If `ingressNginxEnabled` is set to true and `domain` is set as well then the modules will set the hostnames for you (embed.<DOMAIN> will be the embed hostname)           | `list(string)` | `null`        |
| <a name="input_githubCallbackURL"></a> [githubCallbackURL](#input_githubCallbackURL)                            | Authorization callback URL of the Github OAuth app                                                                                                                                                                                                                                                                                                                                                         | `string`       | n/a           |
| <a name="input_githubClientId"></a> [githubClientId](#input_githubClientId)                                     | Client ID of the Github OAuth app.                                                                                                                                                                                                                                                                                                                                                                         | `string`       | n/a           |
| <a name="input_githubClientSecretKey"></a> [githubClientSecretKey](#input_githubClientSecretKey)                | Kubernetes secret key in `githubClientSecretName` that maps to the github client secret. Setting this value only makes sense when `githubClientSecretValue` is null (a kubernetes secret already exists contining the github secret)                                                                                                                                                                       | `string`       | `null`        |
| <a name="input_githubClientSecretName"></a> [githubClientSecretName](#input_githubClientSecretName)             | Kubernetes secret name containing github client secret. Setting this value only makes sense when `githubClientSecretValue` is null (a kubernetes secret already exists contining the github secret)                                                                                                                                                                                                        | `string`       | `null`        |
| <a name="input_githubClientSecretValue"></a> [githubClientSecretValue](#input_githubClientSecretValue)          | Client secret of the Github OAuth app. If not null then a kubernetes secret will be created containing this value.                                                                                                                                                                                                                                                                                         | `string`       | `null`        |
| <a name="input_grpcHostnames"></a> [grpcHostnames](#input_grpcHostnames)                                        | List of domain names for gRPC service used for request capture. Setting this var only makes sense if `ingressNginxEnabled` is set to true. If `ingressNginxEnabled` is set to true and `domain` is not set then this variable can't be null. If `ingressNginxEnabled` is set to true and `domain` is set as well then the modules will set the hostnames for you (grpc.<DOMAIN> will be the grpc hostname) | `list(string)` | `null`        |
| <a name="input_ingressNginxEnabled"></a> [ingressNginxEnabled](#input_ingressNginxEnabled)                      | Whether or not ingress is enabled via nginx                                                                                                                                                                                                                                                                                                                                                                | `bool`         | `false`       |
| <a name="input_namespace"></a> [namespace](#input_namespace)                                                    | Kubernetes namespace where speakeasy will be installed                                                                                                                                                                                                                                                                                                                                                     | `string`       | `"default"`   |
| <a name="input_postgresDSN"></a> [postgresDSN](#input_postgresDSN)                                              | Connection string for a particular data source to store Speakeasy-maintained config and requests. Must be set if createK8sPostgres is false                                                                                                                                                                                                                                                                | `string`       | `null`        |
| <a name="input_serviceAccountId"></a> [serviceAccountId](#input_serviceAccountId)                               | If non-null a private key will be created for the given service accound id and used by speakeasy to authenticate with GCP. This private key will be used instead of the value set in `serviceAccountSecretValue`.                                                                                                                                                                                          | `any`          | `null`        |
| <a name="input_serviceAccountSecretKey"></a> [serviceAccountSecretKey](#input_serviceAccountSecretKey)          | Kubernetes secret key in `serviceAccountSecretName` that maps to the service account private key. Setting this value only makes sense when `serviceAccountSecretValue` is null (a kubernetes secret already exists containing the service account private key)                                                                                                                                             | `any`          | `null`        |
| <a name="input_serviceAccountSecretName"></a> [serviceAccountSecretName](#input_serviceAccountSecretName)       | Kubernetes secret name containing a GCP service account private key (base64 encoded) used by speakeasy to authenticate with GCP. Setting this value only makes sense when `serviceAccountSecretValue` is null (a kubernetes secret already exists containing the service account private key)                                                                                                              | `any`          | `null`        |
| <a name="input_serviceAccountSecretValue"></a> [serviceAccountSecretValue](#input_serviceAccountSecretValue)    | GCP service account private key (base64 encoded) used by speakeasy to authenticate with GCP (e.g. GOOGLE_APPLICATION_CREDENTIALS will be set to this value). For this value to be used `createServiceAccountSecret` should be set to true.                                                                                                                                                                 | `any`          | `null`        |
| <a name="input_signInURL"></a> [signInURL](#input_signInURL)                                                    | The full URL to the Speakeasy homepage the user will be redirected to upon signing in (e.g. `https://www.selfhostspeakeasy.com`)                                                                                                                                                                                                                                                                           | `string`       | n/a           |
| <a name="input_speakeasyName"></a> [speakeasyName](#input_speakeasyName)                                        | Prefix of most resources names                                                                                                                                                                                                                                                                                                                                                                             | `string`       | `"speakeasy"` |
| <a name="input_webHostnames"></a> [webHostnames](#input_webHostnames)                                           | List of domain names for registry web UI. Setting this var only makes sense if `ingressNginxEnabled` is set to true. If `ingressNginxEnabled` is set to true and `domain` is not set then this variable can't be null. If `ingressNginxEnabled` is set to true and `domain` is set as well then the modules will set the hostnames for you (www.<DOMAIN> and <DOMAIN> will be the web hostnames)           | `list(string)` | `null`        |

## Outputs

No outputs.
