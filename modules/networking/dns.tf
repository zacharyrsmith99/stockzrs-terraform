data "aws_route53_zone" "stockzrs_zone" {
  name         = "stockzrs.com."
  private_zone = false
}

resource "aws_route53_record" "apex" {
  zone_id = data.aws_route53_zone.stockzrs_zone.zone_id
  name    = ""
  type    = "A"

  alias {
    name                   = var.ingress_nginx_lb_hostname
    zone_id                = var.ingress_nginx_lb_hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "frontend" {
  zone_id = data.aws_route53_zone.stockzrs_zone.zone_id
  name    = "www"
  type    = "A"

  alias {
    name                   = var.ingress_nginx_lb_hostname
    zone_id                = var.ingress_nginx_lb_hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "stockzrs_relay_service_record" {
  zone_id = data.aws_route53_zone.stockzrs_zone.zone_id
  name    = "stockzrs-relay-service.stockzrs.com"
  type    = "A"

  alias {
    name                   = var.ingress_nginx_lb_hostname
    zone_id                = var.ingress_nginx_lb_hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "stockzrs_metrics_service_record" {
  zone_id = data.aws_route53_zone.stockzrs_zone.zone_id
  name    = "stockzrs-metrics-service.stockzrs.com"
  type    = "A"

  alias {
    name                   = var.ingress_nginx_lb_hostname
    zone_id                = var.ingress_nginx_lb_hosted_zone_id
    evaluate_target_health = true
  }
}


