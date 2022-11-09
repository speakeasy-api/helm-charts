resource "google_dns_managed_zone" "speakeasy_dns_zone" {
  count       = var.domain == null ? 0 : 1
  description = "DNS zone for domain: ${var.domain}"
  dns_name    = "${var.domain}."

  dnssec_config {
    state = "off"
  }

  name       = replace(var.domain, ".", "-")
  visibility = var.domainZoneVisibility
}

resource "google_dns_record_set" "grpc_dns_record" {
  for_each = toset(local.grpcHostnames == null ? [] : local.grpcHostnames)
  name     = "${each.value}."
  type     = "A"
  ttl      = 300

  managed_zone = google_dns_managed_zone.speakeasy_dns_zone[0].name

  rrdatas = [module.speakeasy_k8s.nginx_loadbalancer_ip_or_hostname]
}

resource "google_dns_record_set" "api_dns_record" {
  for_each = toset(local.apiHostnames == null ? [] : local.apiHostnames)
  name     = "${each.value}."
  type     = "A"
  ttl      = 300

  managed_zone = google_dns_managed_zone.speakeasy_dns_zone[0].name

  rrdatas = [module.speakeasy_k8s.nginx_loadbalancer_ip_or_hostname]
}

resource "google_dns_record_set" "web_dns_record" {
  for_each = toset(local.webHostnames == null ? [] : local.webHostnames)
  name     = "${each.value}."
  type     = "A"
  ttl      = 300

  managed_zone = google_dns_managed_zone.speakeasy_dns_zone[0].name

  rrdatas = [module.speakeasy_k8s.nginx_loadbalancer_ip_or_hostname]
}

resource "google_dns_record_set" "embed_dns_record" {
  for_each = toset(local.embedFixtureHostnames == null ? [] : local.embedFixtureHostnames)
  name     = "${each.value}."
  type     = "A"
  ttl      = 300

  managed_zone = google_dns_managed_zone.speakeasy_dns_zone[0].name

  rrdatas = [module.speakeasy_k8s.nginx_loadbalancer_ip_or_hostname]
}
