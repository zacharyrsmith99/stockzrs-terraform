data "aws_route53_zone" "stockzrs_relay_service_zone" {
  name         = "stockzrs.com."
  private_zone = false
}

resource "aws_route53_record" "stockzrs_relay_service_record" {
  zone_id = data.aws_route53_zone.stockzrs_relay_service_zone.zone_id
  name    = "stockzrs-relay-service"
  type    = "CNAME"
  ttl     = "300"
  records = [data.kubernetes_service.ingress_nginx.status.0.load_balancer.0.ingress.0.hostname]
}

