# Speakeasy-k8s

This repository contains the official **Helm 3** chart for installing and configuring
Speakeasy on Kubernetes. For full documentation on deploying Speakeasy on your own
infrastructure, please see the [Self-Hosting Guide[Coming Soon]](https://docs.speakeasyapi.dev/speakeasy-user-guide/self-host-speakeasy-coming-soon).

## Prerequisites

* **Helm 3.0**.
* A PostgreSQL database.
    * We strongly recommend a long-term installation of Speakeasy uses an externally managed database
      (eg. Google CloudSQL, AWS RDS). Tying the storage of your data to the lifecycle of persistent volumes
      may result in data-loss. For testing purposes however, this chart allows the user to enable
      [Postgres on K8s](https://github.com/bitnami/charts/tree/master/bitnami/postgresql).

## Usage

Usage of this chart is currently requires checking out this repository.<br />

`speakeasy-k8s` will soon be packaged in to a Speakeasy helm repo where it may be downloaded. For the time-being, please
follow the sections below to deploy Speakeasy on K8s:
1. Clone this repository:

        git clone https://github.com/speakeasy-api/charts.git

2. Modify the `values.yaml` file:
  #### Ingress
  * Set values for, `registry.ingress.enabled`, `web.ingress.enabled`, and `grpc.ingress.enabled`
    to `true` for any services using ingress provided by `speakeasy-k8s`. Otherwise, set these values to `false`. If ingress
    for any of these services is enabled, `nginx-ingress.enabled` must be set to `true`. Ingress on `speakeasy-k8s` currently assumes an
    `nginx-ingress` controller, but this may be configurable soon. <br /><br />
  * Set values for the corresponding `*.ingress.dns` (and `web.ingress.rootDns` for web) to the respective services'
    domain names where `*.ingress.enabled` is  `true`.
  #### Postgres
  * To enable Postgres on K8s (not recommended), set the value for `postgresql.enabled` to `true`.
  #### Static IP Configuration
  * If there are available static IPs, they may be used for Postgres and nginx-ingress by setting `postgresql.primary.service.loadBalancerIP`
    and `nginx-ingress.controller.service.loadBalancerIP`, respectively. For Postgres, the `127.0.0.1` in the `POSTGRES_DSN`
    value should also be replaced with the static IP.
  #### Speakeasy Version
  * Set values for `registry.image.tag` and `web.image.tag` with the version of Speakeasy you'd like to install. 
3. Install Speakeasy:

        $ helm install speakaesy charts/speakeasy-k8s -n <YOUR_NAMESPACE>

## External Database
It is recommended to disable the included postgresql chart by setting `postgresql.enabled` to `false`. You may specify
the connection to your externally managed Postgres by setting the value of the `POSTGRES_DSN` environment variable in `values.yaml`.

