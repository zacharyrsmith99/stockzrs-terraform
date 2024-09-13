resource "kubernetes_secret" "stockzrs_relay_secrets" {
  metadata {
    name      = "stockzrs-relay-secrets"
    namespace = "stockzrs-relay-service"
  }

  data = var.stockzrs_secrets_configs.stockzrs_relay.secret_string
}

resource "kubernetes_secret" "stockzrs_frontend_secrets" {
  metadata {
    name      = "stockzrs-frontend-secrets"
    namespace = "stockzrs-frontend"
  }

  data = var.stockzrs_secrets_configs.stockzrs_frontend.secret_string
}

resource "kubernetes_secret" "stockzrs_financial_aggregator_service_secrets" {
  metadata {
    name      = "stockzrs-financial-aggregator-secrets"
    namespace = "stockzrs-financial-aggregator-service"
  }

  data = var.stockzrs_secrets_configs.stockzrs_financial_aggregator_service.secret_string
}

resource "kubernetes_secret" "stockzrs_data_persistence_service_secrets" {
  metadata {
    name      = "stockzrs-data-persistence-secrets"
    namespace = "stockzrs-data-persistence-service"
  }

  data = var.stockzrs_secrets_configs.stockzrs_data_persistence_service.secret_string
}

resource "kubernetes_secret" "stockzrs_metrics_service_secrets" {
  metadata {
    name      = "stockzrs-metrics-secrets"
    namespace = "stockzrs-metrics-service"
  }

  data = var.stockzrs_secrets_configs.stockzrs_metrics_service.secret_string
}