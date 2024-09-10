resource "aws_secretsmanager_secret" "stockzrs_relay_config" {
  name = "stockzrs-relay-secrets"
}

resource "aws_secretsmanager_secret_version" "stockzrs_relay_config" {
  secret_id = aws_secretsmanager_secret.stockzrs_relay_config.id
  secret_string = jsonencode({
    NODE_ENV                 = "production"
    LOG_LEVEL                = "info"
    ENVIRONMENT              = "production"
    PORT                     = tostring(var.stockzrs_relay_port)
    TWELVEDATA_API_KEY       = var.twelvedata_api_key
    TWELVEDATA_WS_URL        = "wss://ws.twelvedata.com/v1/quotes/price"
    COINBASE_WS_URL          = "wss://advanced-trade-ws.coinbase.com"
    COINBASE_API_KEY         = var.coinbase_api_key
    COINBASE_API_PRIVATE_KEY = var.coinbase_api_private_key
    KAFKA_BROKER_URL                = var.kafka_bootstrap_server
  })
}

resource "aws_secretsmanager_secret" "stockzrs_frontend_config" {
  name = "stockzrs-frontend-secrets"
}

resource "aws_secretsmanager_secret_version" "stockzrs_frontend_config" {
  secret_id = aws_secretsmanager_secret.stockzrs_frontend_config.id
  secret_string = jsonencode({
    NODE_ENV                      = "production"
    LOG_LEVEL                     = "info"
    ENVIRONMENT                   = "production"
    PORT                          = tostring(var.stockzrs_frontend_port)
    STOCKZRS_RELAY_SERVICE_WS_URL = var.stockzrs_relay_service_ws_url
  })
}

resource "aws_secretsmanager_secret" "stockzrs_kafka_config" {
  name = "stockzrs-kafka-secrets"
}

resource "aws_secretsmanager_secret_version" "stockzrs_kafka_config" {
  secret_id = aws_secretsmanager_secret.stockzrs_kafka_config.id
  secret_string = jsonencode({
    KAFKA_BROKER_URL = var.kafka_bootstrap_server
  })
}
