output "nginx_loadbalancer_ip_or_hostname" {
  type  = string
  value = local.ingressNginxIpOrHostname
}
