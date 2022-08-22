# Speakeasy-k8s

This repository contains the official **Helm 3** chart for installing and configuring
Speakeasy on Kubernetes. For full documentation on deploying Speakeasy on your own
infrastructure, please see the [Self-Hosting Guide](https://docs.speakeasyapi.dev/speakeasy-user-guide/self-host-speakeasy-coming-soon).

## Prerequisites

* **Helm 3.0**
* **kubectl**
* A PostgreSQL database.
    * We strongly recommend a long-term installation of Speakeasy uses an externally managed database
      (eg. Google CloudSQL, AWS RDS). Tying the storage of your data to the lifecycle of persistent volumes
      may result in data-loss. For testing purposes however, this chart allows the user to enable
      [Postgres on K8s](https://github.com/bitnami/charts/tree/master/bitnami/postgresql).

## Usage

Usage of this chart is currently requires checking out this repository. <br />

`speakeasy-k8s` will soon be packaged in to a Speakeasy helm repo where it may be downloaded. For the time-being, please
follow the sections below to deploy Speakeasy on K8s:
1. Clone this repository and navigate to `charts` directory:

        git clone https://github.com/speakeasy-api/charts.git
        cd charts

2. Provide an overlay for the changes needed to `values.yaml`:
  #### Auth
  Follow the [Firebase Setup](https://docs.speakeasyapi.dev/speakeasy-user-guide/self-host-speakeasy-coming-soon/google-cloud-platform#firebase-setup)
  and specify values for `auth.EmailSignInURL`, `auth.GIPAuthDomain`, and `auth.GIPApiKey`.
  #### Ingress
  * If provisioning ingress resources from our chart, set the value for `registry.ingress.enabled` to `true`.

[//]: # (Following instruction will be relevant once we provide a method for fixing the IP of ingress-nginx's LoadBalancer service
or use ExternalDNS)
[//]: # (  * If provisioning an ingress controller from our chart, set the value for `ingress-nginx.enabled` to `true`.)
  * If `registry.ingress.enabled` is `true`, set the values for `registry.ingress.apiHostnames`, `registry.ingress.webHostnames`,
    and `registry.ingress.grpcHostnames` to your specified domain names for Speakeasy's registry API, web, and gRPC services.

  #### Postgres
  To enable Postgres on K8s (not recommended), set the value for `postgresql.enabled` to `true`. If using an externally
  managed Postgres (recommended), set `postgresql.enabled` to `false` and the value for the `POSTGRES_DSN` environment variable.
  #### Enable HTTPS
  If `registry.ingress.enabled` is `true`, set the value for `cert-manager.enabled` to `true` (and `notificationEmail` to receive updates about cert expiry)
  for LetsEncrypt to provide SSL certificates to enable HTTPS.
  #### Speakeasy Version
  Set values for `registry.image.tag` with the version of Speakeasy you'd like to install.

The following is a sample overlay file for a configuration requiring ingress to be spun up by this chart and connecting to
an externally managed Postgres:
```
registry:
  envVars:
      - key: POSTGRES_DSN
        value: postgres://postgres:postgres@34.149.47.53:5432/postgres?sslmode=disable
  ingress:
    enabled: true
    apiHostnames:
      - api.selfhostspeakeasy.com
    webHostnames:
      - www.selfhostspeakeasy.com
      - selfhostspeakeasy.com
    grpcHostnames:
      - grpc.selfhostspeakeasy.com
auth:
  EmailSignInURL: "https://www.selfhostspeakeasy.com"
  GIPAuthDomain: "speakeasy-selfhost.firebaseapp.com"
  GIPApiKey: "AIbaaefCUa3a3242zUC_YeLeK1aba3_h-KrEB"
postgresql:
  enabled: false
cert-manager:
  enabled: true
```

3. Install Speakeasy.

   ### Without Ingress
   If _not_ enabling ingress, execute the following commands:
   ```
   helm dependency update speakeasy-k8s
   helm install speakeasy speakeasy-k8s -f <OVERLAY> -n <NAMESPACE> --debug
   ```
   If `postgresql.enabled` is `true`, you will also need to edit the Speakeasy deployment to modify the IP in `POSTGRES_DSN`
   with the external IP of the `LoadBalancer` service. First, get the IP via:
   ```
   kubectl get svc -n <NAMESPACE>
   ```
   Then, modify the Speakeasy deployment via:
   ```
   kubectl edit deploy speakeasy-k8s-service -n <NAMESPACE>
   ```
   Swap out the `127.0.0.1` under the `value` for `POSTGRES_DSN` with the IP obtained from the previous command.

   ### With Ingress

   If enabling ingress and `cert-manager`, there are strict requirements regarding the ordering of resources. See 
   [Resource Ordering Constraints](#resource-ordering-constraints) for an explanation. In this case, please execute the following steps:
   1. First, update dependencies:
   ```
   helm dependency update speakeasy-k8s
   ```
   2. Install `ingress-nginx`:
      ```
      helm install ingress speakeasy-k8s/charts/ingress-nginx-4.0.13.tgz --set controller.config.use-forwarded-headers=true --set controller.config.use-http2=true
      ```
      Get the external IP of the `LoadBalancer` via:
      ```
      kubectl get svc -n <NAMESPACE>
      ```
      Then, create A records on your DNS to point your `registry.ingress.*Hostnames` domains to this IP.
   3. In your overlay, set `postgresql.enabled` to `false`, even if using [Postgres on K8s](https://github.com/bitnami/charts/tree/master/bitnami/postgresql).
      If not using an externally managed Postgres, follow necessary instructions to install the `postgresql` helm chart.
      The following is a sample command using an already existing PV and PVC:
      ```
      helm install postgres speakeasy-k8s/charts/postgresql-11.6.24.tgz --set persistence.existingClaim=postgres-pvc --set auth.postgresPassword=postgres --set volumePermissions.enabled=true --set primary.service.type=LoadBalancer 
      ```
   4. For K8s Postgres, get the external IP of the `LoadBalancer` via:
      ```
      kubectl get svc -n <NAMESPACE>
      ```
      Otherwise, simply get the appropriate IP from your externally managed Postgres. <br /><br />
      In your overlay, modify `POSTGRES_DSN` value to use the IP obtained in the above instructions.
   5. Finally, install `speakeasy-k8s`:
      ```
      helm install speakeasy speakeasy-k8s -f <OVERLAY> -n <NAMESPACE> --timeout 5m --wait --wait-for-jobs --debug
      ```
   
   ### Additional Notes

   #### Resource Ordering Constraints
   `cert-manager` installs CRDs to enable certificate provisioning via LetsEncrypt. One such CRD is the `ClusterIssuer` which
   must be installed last, otherwise the CRD will not be present in the K8s API server. However, the `CertificateRequest` will
   issue a status check to the `ClusterIssuer`. When this status check fails, we found the `CertificateRequest` status would hang
   and prevent a successful installation. Since this status check proceeds directly upon installation of Speakeasy, we need to ensure
   the `POSTGRES_DSN` is pointing to an already existing Postgres service and A records are created for the `ingress-nginx` controller
   beforehand for a successful Speakeasy installation.
   
