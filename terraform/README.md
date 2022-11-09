# Speakeasy Terraform Modules

- `k8s`: installs speakeasy on a kubernetes cluster. It will also install `postgresql`, `cert-manager` and `nginx` in your kubernetes cluster depending on the variables you set.
- `aws`: makes use of the k8s module. Provides the same features as the k8s module and can also create Route53 zones and A records
- `gcp`: makes use of the k8s module. Provides the same features as the k8s module, can create necessary service accounts needed to run on GCP and can also create CloudDNS zones and A records
