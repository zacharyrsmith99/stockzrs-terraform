resource "aws_secretsmanager_secret" "stockzrs_relay_config" {
  name = "stockzrs-relay-secrets1"
}

resource "aws_secretsmanager_secret_version" "stockzrs_relay_config" {
  secret_id = aws_secretsmanager_secret.stockzrs_relay_config.id
  secret_string = jsonencode({
    NODE_ENV                 = "production"
    LOG_LEVEL                = "info"
    ENVIRONMENT              = "production"
    PORT                     = tostring(var.stockzrs_port)
    TWELVEDATA_API_KEY       = ""
    TWELVEDATA_WS_URL        = ""
    COINBASE_WS_URL          = ""
    COINBASE_API_KEY         = ""
    COINBASE_API_PRIVATE_KEY = ""
  })
}
