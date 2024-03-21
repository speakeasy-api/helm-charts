# Speakeasy K8s Terraform Module

Terraform module that installs Speakeasy on a Kubernetes cluster. The main goal of this module is to support moving towards a single-action install of Speakeasy in the self-hosted scenario.

Depending on the variables you set, this module will do all or some of the following actions:

- Install speakeasy container(s) in the given kubernetes cluster
- Install postgresql in the given kubernetes cluster
- Install cert-manager in the given kubernetes cluster
- Instanll nginx in the given kubernetes cluster

## Instructions

Even though we'd like this module to be a single-action install of Speakeasy, it isn't quite there yet. There are still things we need to do before and after installing the module. Go through the following steps to get speakeasy up and running using the module:

1. **Register a domain and create A records for your domain**: domain that will point to your speakeasy instance. For this you can use any domain registrar. Worth noting that this step is not 100% necessary: you can still get speakeasy working without registering a domain using `kubectl portforward`.
1. **Set up OAuth on Github**: Speakeasy uses Github OAuth to provide authentication for your org. Under settings for the Github Organization you'd like to authenticate (or your personal profile) , click `Developer Settings" > Oauth Apps > New Oauth App`. Fill in the fields as follows:

   - Homepage URL: `https://<MY_DOMAIN>`
   - Authorization callback URL: `https://<MY_DOMAIN>/v1/auth/callback/github`

1. **Get Client ID and Client Secret**: After registering your application in the previous step you'll be redirected to a configuration view of the application you just registered. The value under `Client ID` should be the value you set on the module's `githubClientId` variable. Similarly, under `Client secrets` you'll click on `Generate a new client secret` and the provided secret should be the value you set on the module's `githubClientSecretValue`.
1. **Install terraform module**: you'll need to have the following providers:

   - kubernetes provider pointing to the kubernetes cluster where you'd like speakeasy to be installed
   - helm provider pointing to the kubernetes cluster where you'd like speakeasy to be installed
   - google provider pointing to the project where you'd like speakeasy to be installed

   Once you have the above then you are good to make use of the module and install speakeasy running `terraform init && terraform apply`.

1. **Update name servers**: If the module created a domain zone for you then most likely you'll need to update the domain's name servers to point to the ones in the newly created zone.

Done! Your speakeasy instance might not be available right away - you might have to wait a few minutes for the DNS changes to propagate.

## Requirements

| Name                                                                        | Version   |
| --------------------------------------------------------------------------- | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform)    | ~> 1.3.1  |
| <a name="requirement_helm"></a> [helm](#requirement_helm)                   | >= 2.7.0  |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement_kubernetes) | >= 2.14.0 |

## Providers

| Name                                                                  | Version   |
| --------------------------------------------------------------------- | --------- |
| <a name="provider_helm"></a> [helm](#provider_helm)                   | >= 2.7.0  |
| <a name="provider_kubernetes"></a> [kubernetes](#provider_kubernetes) | >= 2.14.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                                           | Type        |
| ---------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [helm_release.cert_manager](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)                              | resource    |
| [helm_release.ingress_nginx](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)                             | resource    |
| [helm_release.postgres_k8s](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)                              | resource    |
| [helm_release.speakeasy](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)                                 | resource    |
| [kubernetes_secret.registry_service_account_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource    |
| [kubernetes_service.ingress_nginx](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/service)              | data source |
| [kubernetes_service.postgres](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/service)                   | data source |

## Inputs

| Name                                                                                                                  | Description                                                                                                                                                                                                                                                                                   | Type           | Default       |
| --------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------------- |
| <a name="input_apiHostnames"></a> [apiHostnames](#input_apiHostnames)                                                 | List of domain names for registry api. You must set this variable if `ingressNginxEnabled` is set to true.                                                                                                                                                                                    | `list(string)` | `null`        |
| <a name="input_cloudProvider"></a> [cloudProvider](#input_cloudProvider)                                              | Cloud provider where speakeasy will be running. Set to null if speakeasy won't be running in the cloud                                                                                                                                                                                        | `string`       | `null`        |
| <a name="input_controllerStaticIpOrHostname"></a> [controllerStaticIpOrHostname](#input_controllerStaticIpOrHostname) | static public hostname/ip to be used on nginx's controller.                                                                                                                                                                                                                                   | `string`       | `null`        |
| <a name="input_createK8sPostgres"></a> [createK8sPostgres](#input_createK8sPostgres)                                  | If true, a postgresql database will be installed on EKS alongside speakeasy. This is not recommended for production, you should think of this database as a non persistent database                                                                                                           | `bool`         | `false`       |
| <a name="input_createServiceAccountSecret"></a> [createServiceAccountSecret](#input_createServiceAccountSecret)       | If true a kubernetes secret will be created containing the non-null value specified in `serviceAccountSecretValue`. If false, then `serviceAccountSecretValue` will be ignored.                                                                                                               | `bool`         | `false`       |
| <a name="input_githubCallbackURL"></a> [githubCallbackURL](#input_githubCallbackURL)                                  | Your application’s callback URL (e.g. `https://api.selfhostspeakeasy.com/v1/auth/callback/github`)                                                                                                                                                                                            | `string`       | `null`        |
| <a name="input_githubClientId"></a> [githubClientId](#input_githubClientId)                                           | Client ID of the Github Oauth app.                                                                                                                                                                                                                                                            | `string`       | `null`        |
| <a name="input_githubClientSecretKey"></a> [githubClientSecretKey](#input_githubClientSecretKey)                      | Kubernetes secret key in `githubClientSecretName` that maps to the github client secret. Setting this value only makes sense when `githubClientSecretValue` is null (a kubernetes secret already exists contining the github secret)                                                          | `string`       | `null`        |
| <a name="input_githubClientSecretName"></a> [githubClientSecretName](#input_githubClientSecretName)                   | Kubernetes secret name containing github client secret. Setting this value only makes sense when `githubClientSecretValue` is null (a kubernetes secret already exists contining the github secret)                                                                                           | `string`       | `null`        |
| <a name="input_githubClientSecretValue"></a> [githubClientSecretValue](#input_githubClientSecretValue)                | Client secret of the Github Oauth app. If not null then a kubernetes secret will be created containing this value.                                                                                                                                                                            | `string`       | `null`        |
| <a name="input_grpcHostnames"></a> [grpcHostnames](#input_grpcHostnames)                                              | List of domain names for gRPC service used for request capture. You must set this variable if `ingressNginxEnabled` is set to true.                                                                                                                                                           | `list(string)` | `null`        |
| <a name="input_ingressNginxEnabled"></a> [ingressNginxEnabled](#input_ingressNginxEnabled)                            | Whether or not ingress is enabled via nginx                                                                                                                                                                                                                                                   | `bool`         | `false`       |
| <a name="input_namespace"></a> [namespace](#input_namespace)                                                          | Kubernetes namespace where speakeasy will be installed                                                                                                                                                                                                                                        | `string`       | `"default"`   |
| <a name="input_postgresDSN"></a> [postgresDSN](#input_postgresDSN)                                                    | Connection string for a particular data source to store Speakeasy-maintained config and requests. Must be set if createK8sPostgres is false                                                                                                                                                   | `string`       | `null`        |
| <a name="input_serviceAccountSecretKey"></a> [serviceAccountSecretKey](#input_serviceAccountSecretKey)                | Kubernetes secret key in `serviceAccountSecretName` that maps to the service account private key. Setting this value only makes sense when `serviceAccountSecretValue` is null (a kubernetes secret already exists containing the service account private key)                                | `string`       | `null`        |
| <a name="input_serviceAccountSecretName"></a> [serviceAccountSecretName](#input_serviceAccountSecretName)             | Kubernetes secret name containing a GCP service account private key (base64 encoded) used by speakeasy to authenticate with GCP. Setting this value only makes sense when `serviceAccountSecretValue` is null (a kubernetes secret already exists containing the service account private key) | `string`       | `null`        |
| <a name="input_serviceAccountSecretValue"></a> [serviceAccountSecretValue](#input_serviceAccountSecretValue)          | GCP service account private key (base64 encoded) used by speakeasy to authenticate with GCP (e.g. GOOGLE_APPLICATION_CREDENTIALS will be set to this value). For this value to be used `createServiceAccountSecret` should be set to true.                                                    | `string`       | `null`        |
| <a name="input_signInURL"></a> [signInURL](#input_signInURL)                                                          | The full URL to the Speakeasy homepage the user will be redirected to upon signing in (e.g. `https://www.selfhostspeakeasy.com`)                                                                                                                                                              | `string`       | `null`        |
| <a name="input_speakeasyName"></a> [speakeasyName](#input_speakeasyName)                                              | Prefix of most resources names                                                                                                                                                                                                                                                                | `string`       | `"speakeasy"` |
| <a name="input_webHostnames"></a> [webHostnames](#input_webHostnames)                                                 | List of domain names for registry web UI. You must set this variable if `ingressNginxEnabled` is set to true.                                                                                                                                                                                 | `list(string)` | `null`        |

## Outputs

| Name                                                                                                                                   | Description |
| -------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_nginx_loadbalancer_ip_or_hostname"></a> [nginx_loadbalancer_ip_or_hostname](#output_nginx_loadbalancer_ip_or_hostname) | n/a         |
