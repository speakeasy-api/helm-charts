output "nginx_loadbalancer_ip_or_hostname" {
  value       = local.ingressNginxIpOrHostname
  description = "nginx's load balancer static ip or hostname"
}
