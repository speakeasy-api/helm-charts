### emissary-ingress

To use Ambassador's `emissary-ingress` controller, please ensure the following values are set to `false`:

    registry.ingress.enabled
    cert-manager.enabled

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
   Then, create A records on your DNS to point your desired domains for Speakeasy's web and gRPC services to this IP. For example domain names, refer to
   the sample overlay in the end of the [Configuration](../README.md#configuration) section.
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
   and `emissary-ingress` to enable this. Replace the "$YOUR_EMAIL_HERE$" in `./ambassador/cert-manager-ambassador-crds.yaml`
   to the email updates to manage the LetsEncrypt certificate (90 day expiration) will be sent.<br/><br/>
   Then, apply the file:
   ```
   kubectl apply -f ./cert-manager-ambassador-crds.yaml --namespace=<NAMESPACE>
   ```
6. Now, we have to provision a certificate for each of our Speakeasy domains.

   In `./ambassador-web-cert.yaml` and `./ambassador-grpc-cert.yaml`, ensure the "$" wrapped value in `spec.dnsNames` is replaced with the corresponding
   domain name for the A record you issued above.

   Then deploy each certificate:

   ```
   kubectl apply -f ./ambassador-web-cert.yaml --namespace <NAMESPACE>
   kubectl apply -f ./ambassador-grpc-cert.yaml --namespace <NAMESPACE>
   ```

   You may monitor the status of each certificate by issuing the following command
   and watching the "READY" column:

   ```
   kubectl get certificates -n <NAMESPACE> --watch
   ```

7. The certificates from the previous step should now be ready. In `./ambassador/ambassador-mappings-and-hosts.yaml`, replace
   all the "$" wrapped values for `spec.hostname`, and ensure they're equivalent to the domain names for the A record you
   issued above.<br/><br/>
   Then, apply the file:
   ```
   kubectl apply -f ./ambassador-mappings-and-hosts.yaml --namespace=<NAMESPACE>
   ```
