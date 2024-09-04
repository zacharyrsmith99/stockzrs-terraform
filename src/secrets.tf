resource "aws_secretsmanager_secret" "stockzrs_relay_config" {
  name = "stockzrs-relay-secrets1"
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
  })
}
