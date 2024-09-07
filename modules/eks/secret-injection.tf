resource "kubernetes_secret" "stockzrs_relay_secrets" {
  metadata {
    name      = "stockzrs-relay-secrets"
    namespace = "stockzrs-relay-service"
  }

  data = var.stockzrs_secrets_configs.stockzrs_relay.secret_string
}