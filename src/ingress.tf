resource "helm_release" "external_nginx" {
  name = "external"

  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress"
  create_namespace = true
  version          = "4.10.1"

  values = [file("${path.module}/k8s/ingress/external-nginx.yaml")]

  set {
    name  = "controller.ingressClassResource.name"
    value = "external-nginx"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "external"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-nlb-target-type"
    value = "ip"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
    value = "internet-facing"
  }

  depends_on = [helm_release.aws_lbc]
}

data "kubernetes_service" "ingress_nginx" {
  metadata {
    name      = "external-ingress-nginx-controller"
    namespace = "ingress"
  }
}

resource "kubernetes_ingress_v1" "stockzrs_relay_service_ingress" {
  metadata {
    name      = "stockzrs-relay-service"
    namespace = "stockzrs-relay-service"
    annotations = {
      "cert-manager.io/cluster-issuer"                    = "stockzrs-relay-service"
      "kubernetes.io/ingress.class"                       = "nginx"
      "nginx.ingress.kubernetes.io/proxy-read-timeout"    = "3600"
      "nginx.ingress.kubernetes.io/proxy-send-timeout"    = "3600"
      "nginx.ingress.kubernetes.io/proxy-connect-timeout" = "3600"
      "nginx.ingress.kubernetes.io/proxy-http-version"    = "1.1"
      "nginx.ingress.kubernetes.io/websocket-services"    = "stockzrs-relay-service"
    }
  }
  spec {
    ingress_class_name = "external-nginx"
    tls {
      hosts       = ["stockzrs-relay-service.stockzrs.com"]
      secret_name = "stockzrs-relay-service-tls"
    }
    rule {
      host = "stockzrs-relay-service.stockzrs.com"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "stockzrs-relay-service"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
