# Speakeasy-k8s

This repository contains the official **Helm 3** chart for installing and configuring
Speakeasy on Kubernetes. For full documentation on deploying Speakeasy on your own
infrastructure, please see the [Self-Hosting Guide](https://docs.speakeasyapi.dev/speakeasy-user-guide/self-host-speakeasy-coming-soon).

### Prerequisites

* **Helm 3.0**
* **kubectl**
* A PostgreSQL database.
    * We strongly recommend a long-term installation of Speakeasy uses an externally managed database
      (eg. Google CloudSQL, AWS RDS). Tying the storage of your data to the lifecycle of persistent volumes
      may result in data-loss. For testing purposes however, this chart allows the user to enable
      [Postgres on K8s](https://github.com/bitnami/charts/tree/master/bitnami/postgresql).

## Usage

[Helm](https://helm.sh) must be installed to use the charts.  Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.

Once Helm has been set up correctly, add the repo as follows:

    helm repo add speakeasy https://speakeasy-api.github.io/helm-charts

If you had already added this repo earlier, run `helm repo update` to retrieve
the latest versions of the packages. You can then run `helm search repo
speakeasy` to see the charts.

For specific instructions regarding installation of speakeasy-k8s, please refer to the [Installation](#installation) section
below.

## Configuration

Provide an overlay for the changes needed to `values.yaml` by following the sections below.

### Auth
Follow the [Firebase Setup](https://docs.speakeasyapi.dev/speakeasy-user-guide/self-host-speakeasy-coming-soon/google-cloud-platform#firebase-setup)
and specify values for `auth.EmailSignInURL`, `auth.GIPAuthDomain`, and `auth.GIPApiKey`.
### Ingress
If provisioning ingress resources from our chart, set the value for `registry.ingress.enabled` to `true`.
Also, set the values for `registry.ingress.apiHostnames`, `registry.ingress.webHostnames`,
and `registry.ingress.grpcHostnames` to your specified domain names for Speakeasy's registry API, web, and gRPC services.
### Ambassador
If using Ambassador mappings, set `emissary-ingress.enabled` to `true` and ensure `registry.ingress.enabled`,
`cert-manager.enabled`, and `ingress-nginx.enabled` are all `false`.
See the [Ambassador Installation](#emissary-ingress) section below for the steps required to use Ambassador for your Speakeasy
deployment.

[//]: # (Following instruction will be relevant once we provide a method for fixing the IP of ingress-nginx's LoadBalancer service
or use ExternalDNS)
[//]: # (  * If provisioning an ingress controller from our chart, set the value for `ingress-nginx.enabled` to `true`.)

### Postgres
To enable Postgres on K8s (not recommended), set the value for `postgresql.enabled` to `true`. If using an externally
managed Postgres (recommended), set `postgresql.enabled` to `false` and the value for the `POSTGRES_DSN` environment variable.
### Bigquery
To enable Bigquery for request/response storage, set values for `BIGQUERY_PROJECT` and `BIGQUERY_DATASET` under the
`registry.envVars` block. They should be equivalent to the GCP project ID and Bigquery dataset ID, respectively, under which `bounded_requests`
and `unbounded_requests` tables must exist with the following schema:

**bounded_requests**

![](<../../assets/Screen Shot 2022-09-05 at 7.06.25 PM.png>)

**unbounded_requests**

![](<../../assets/Screen Shot 2022-09-05 at 7.06.39 PM.png>)

Currently, the Speakeasy application assumes these tables with the above schemas exist under the specified `BIGQUERY_PROJECT`
and `BIGQUERY_DATASET`. We will soon add support for automating the creation of these tables in your GCP project if they do not exist.

[//]: # (insert picture here)
### Enable HTTPS
If `registry.ingress.enabled` is `true`, set the value for `cert-manager.enabled` to `true` (and `notificationEmail` to receive updates about cert expiry)
for LetsEncrypt to provide SSL certificates to enable HTTPS.

If following the [Ambassador Installation](#emissary-ingress), ensure `cert-manager.enabled` is `false`. Some manual steps will be required to ensure certificates can successfully provision
with Ambassador mappings.
### Speakeasy Version
Set values for `registry.image.tag` with the version of Speakeasy you'd like to install.

The following is a sample overlay file for a configuration requiring ingress to be spun up by this chart and connecting to
an externally managed Postgres:
```
registry:
  image:
    tag: 1.0.0
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
## Installation

The process to install Speakeasy will differ depending on whether ingress, Ambassador, or neither are enabled.

### Without Ingress
If _not_ enabling ingress or Ambassador, execute the following command:

    helm install speakeasy speakeasy/speakeasy-k8s -f <OVERLAY> -n <NAMESPACE> --debug

If `postgresql.enabled` is `true`, you will also need to edit the Speakeasy deployment to modify the IP in `POSTGRES_DSN`
with the external IP of the `LoadBalancer` service. First, get the IP via:

    kubectl get svc -n <NAMESPACE> postgres-postgresql -o "go-template={{range .status.loadBalancer.ingress}}{{or .ip .hostname}}{{end}}"

Then, modify the Speakeasy deployment via:

    kubectl edit deploy -n <NAMESPACE> speakeasy-k8s-service

Swap out the `127.0.0.1` under the `value` for `POSTGRES_DSN` with the IP obtained from the previous command.

### With Ingress

In your overlay, set `postgresql.enabled` to `false`, even if using [Postgres on K8s](https://github.com/bitnami/charts/tree/master/bitnami/postgresql).
If using K8s Postgres, follow necessary instructions to install the `postgresql` helm chart.
The following is a sample command using an already existing PV and PVC:
   ```
   helm repo add bitnami https://charts.bitnami.com/bitnami
   helm repo update
   helm install -n <NAMESPACE> postgres bitnami/postgresql --set persistence.existingClaim=postgres-pvc --set auth.postgresPassword=postgres \
   --set volumePermissions.enabled=true --set primary.service.type=LoadBalancer
   ```
For K8s Postgres, get the external IP of the `LoadBalancer` via:
   ```
   kubectl get svc -n <NAMESPACE> postgres-postgresql -o "go-template={{range .status.loadBalancer.ingress}}{{or .ip .hostname}}{{end}}"
   ```
Otherwise, simply get the appropriate IP from your externally managed Postgres. <br /><br />
In your overlay, modify `POSTGRES_DSN` value to use the IP obtained in the above instructions.

#### ingress-nginx

If enabling ingress and `cert-manager`, there are strict requirements regarding the ordering of resources. See
[Resource Ordering Constraints](#resource-ordering-constraints) for an explanation. As a result, please ensure
`ingress-nginx.enabled` is set to `false`, and execute the following steps:
1. First, install `ingress-nginx`:
   ```
   helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
   helm repo update
   helm install -n <NAMESPACE> ingress ingress-nginx/ingress-nginx --set controller.config.use-forwarded-headers=true \
   --set controller.config.use-http2=true --set fullnameOverride=speakeasy-ingress-nginx
   ```
2. Get the external IP of the `LoadBalancer` via:
   ```
   kubectl get svc speakeasy-ingress-nginx-controller -o "go-template={{range .status.loadBalancer.ingress}}{{or .ip .hostname}}{{end}}"
   ```
   Then, create A records on your DNS to point your `registry.ingress.*Hostnames` domains to this IP.

#### emissary-ingress

To use Ambassador's `emissary-ingress` controller, please ensure the following values are set to `false`:

    registry.ingress.enabled
    cert-manager.enabled
    ingress-nginx.enabled
Execute the following steps:
1. First, add CRDs for `emissary-ingress`:
    ```
   helm repo add datawire https://app.getambassador.io
   helm repo update
   kubectl apply -f https://app.getambassador.io/yaml/emissary/3.1.0/emissary-crds.yaml
    ```
2. Install `emissary-ingress`:
   ```
   helm install -n <NAMESPACE> emissary-ingress datawire/emissary-ingress && kubectl wait --for condition=available --timeout=90s deploy \
    -lapp.kubernetes.io/instance=emissary-ingress
   ```
3. Get the external IP of the `LoadBalancer` via:
   ```
   kubectl get svc -n <NAMESPACE> emissary-ingress -o "go-template={{range .status.loadBalancer.ingress}}{{or .ip .hostname}}{{end}}"
   ```
   Then, create A records on your DNS to point your desired domains for Speakeasy's API, gRPC, web, and root web
   services to this IP. For example domain names, refer to the sample overlay in the end of the [Configuration](#configuration) section above.
4. Install `cert-manager` with the following overlay:
    ```
   installCRDs: true
   podDnsPolicy: None
   podDnsConfig:
     nameservers:
       - 8.8.8.8
       - 1.1.1.1
       - 208.67.222.222
    ```
   Execute the following:
    ```
   helm repo add jetstack https://charts.jetstack.io
   helm repo update
   helm install -n <NAMESPACE> cert-manager jetstack/cert-manager -f <OVERLAY>
    ```
5. `cert-manager` must issue an HTTP-01 challenge to verify domain ownership. We will need to apply CRDs from both `cert-manager`
   and `emissary-ingress` to enable this. Replace all fields in `./ambassador/cert-manager-ambassador-crds.yaml`
   surrounded by `$` with specific values. Ensure the values under `spec.dnsNames` are equivalent to the domain names
   for the A records you issued above.<br/><br/>
   Then, apply the file:
   ```
   kubectl apply -f <path/to/ambassador/cert-manager-ambassador-crds.yaml> --namespace=<NAMESPACE>
   ```
   It will take a few minutes for the challenge to resolve. You can monitor the status of the certificate by issuing
   the following command and watching the "READY" column:
   ```
   kubectl get certificates -n <NAMESPACE> --watch
   ```
6. Once the challenge from the previous step is resolved, replace all fields in `./ambassador/ambassador-mappings-and-hosts.yaml`
   surrounded by `$` with specific values. Ensure the values under `spec.hostname` for each resource are equivalent to the
   domain names for the A records you issued above.<br/><br/>
   Then, apply the file:
   ```
   kubectl apply -f <path/to/ambassador/ambassador-mappings-and-hosts.yaml> --namespace=<NAMESPACE>
   ```

Finally, execute the following install for `speakeasy-k8s`:
```
helm install speakeasy speakeasy/speakeasy-k8s -f <OVERLAY> -n <NAMESPACE> --timeout 5m --wait --wait-for-jobs --debug \
--set fullnameOverride=speakeasy
```

After waiting a couple minutes, Speakeasy should now be running successfully in your environment. You should
now be able to access the HTTPS endpoint for your web or root web hostname.<br /><br />
To uninstall the charts:

    helm delete speakeasy -n <NAMESPACE>
    helm delete ingress -n <NAMESPACE>
    helm delete postgres -n <NAMESPACE>



#### Resource Ordering Constraints
`cert-manager` installs CRDs to enable certificate provisioning via LetsEncrypt. One such CRD is the `ClusterIssuer` which
must be installed last, otherwise the CRD will not be present in the K8s API server. However, the `CertificateRequest` will
issue a status check to the `ClusterIssuer`. When this status check fails, we found the `CertificateRequest` status would hang
and prevent a successful installation. Since this status check proceeds directly upon installation of Speakeasy, we need to ensure
the `POSTGRES_DSN` is pointing to an already existing Postgres service and A records are created for the `ingress-nginx` controller
beforehand for a successful Speakeasy installation.
   
