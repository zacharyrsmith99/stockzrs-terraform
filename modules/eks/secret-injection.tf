resource "kubernetes_secret" "stockzrs_relay_secrets" {
  metadata {
    name      = "stockzrs-relay-secrets"
    namespace = "stockzrs-relay-service"
  }

  data = var.stockzrs_secrets_configs.stockzrs_relay.secret_string
}

resource "kubernetes_secret" "stockzrs_financial_aggregator_service_secrets" {
  metadata {
    name      = "stockzrs-financial-aggregator-secrets"
    namespace = "stockzrs-financial-aggregator-service"
  }

  data = var.stockzrs_secrets_configs.stockzrs_financial_aggregator_service.secret_string
}