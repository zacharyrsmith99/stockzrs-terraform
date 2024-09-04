resource "helm_release" "cert_manager" {
  name = "cert-manager"

  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = "v1.15.0"

  set {
    name  = "installCRDs"
    value = "true"
  }

  depends_on = [helm_release.external_nginx]
}

resource "kubernetes_manifest" "cluster_issuer_stockzrs_relay_service" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "stockzrs-relay-service"
    }
    spec = {
      acme = {
        email  = "zachary.r.smith99@gmail.com"
        server = "https://acme-v02.api.letsencrypt.org/directory"
        privateKeySecretRef = {
          name = "stockzrs-relay-service-cluster-issuer"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                ingressClassName = "external-nginx"
              }
            }
          }
        ]
      }
    }
  }

  depends_on = [helm_release.cert_manager]
}