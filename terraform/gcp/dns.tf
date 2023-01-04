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

resource "google_dns_record_set" "wildcard_dns_record" {
  name = "*.${var.domain}."
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.speakeasy_dns_zone[0].name

  rrdatas = [module.speakeasy_k8s.nginx_loadbalancer_ip_or_hostname]
}

resource "google_dns_record_set" "domain_dns_record" {
  name = "${var.domain}."
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.speakeasy_dns_zone[0].name

  rrdatas = [module.speakeasy_k8s.nginx_loadbalancer_ip_or_hostname]
}
