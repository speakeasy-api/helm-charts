resource "aws_route53_zone" "speakeasy_dns_zone" {
  count = var.domain == null ? 0 : 1
  name  = var.domain

  dynamic "vpc" {
    for_each = var.privateZoneVpcId == null ? toset([]) : toset([1])
    content {
      vpc_id = var.privateZoneVpcId
    }
  }
}

data "aws_elb_hosted_zone_id" "main" {}

resource "aws_route53_record" "wildcard_dns_record" {
  zone_id = aws_route53_zone.speakeasy_dns_zone[0].zone_id
  name    = "*.${var.domain}"
  type    = "A"

  alias {
    name                   = module.speakeasy_k8s.nginx_loadbalancer_ip_or_hostname
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "domain_dns_record" {
  zone_id = aws_route53_zone.speakeasy_dns_zone[0].zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = module.speakeasy_k8s.nginx_loadbalancer_ip_or_hostname
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }
}


