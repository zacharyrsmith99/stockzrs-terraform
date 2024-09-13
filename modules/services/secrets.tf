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
    KAFKA_BOOTSTRAP_SERVERS  = var.kafka_bootstrap_server
    KAFKA_USERNAME           = var.kafka_users.stockzrs_relay_service.username
    KAFKA_PASSWORD           = var.kafka_users.stockzrs_relay_service.password
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
    STOCKZRS_METRICS_SERVICE_URL = "stockzrs-metrics-service.stockzrs-metrics-service.svc.cluster.local"
  })
}

resource "aws_secretsmanager_secret" "stockzrs_kafka_config" {
  name = "stockzrs-kafka-secrets"
}

resource "aws_secretsmanager_secret_version" "stockzrs_kafka_config" {
  secret_id = aws_secretsmanager_secret.stockzrs_kafka_config.id
  secret_string = jsonencode({
    KAFKA_BOOTSTRAP_SERVERS = var.kafka_bootstrap_server
    KAFKA_ADMIN_USERNAME    = var.kafka_users.admin.username
    KAFKA_ADMIN_PASSWORD    = var.kafka_users.admin.password
  })
}

resource "aws_secretsmanager_secret" "stockzrs_financial_aggregator_service_config" {
  name = "stockzrs-financial-aggregator-service-secrets"
}

resource "aws_secretsmanager_secret_version" "stockzrs_financial_aggregator_service_config" {
  secret_id = aws_secretsmanager_secret.stockzrs_financial_aggregator_service_config.id
  secret_string = jsonencode({
    KAFKA_BOOTSTRAP_SERVERS           = var.kafka_bootstrap_server
    NODE_ENV                          = "production"
    LOG_LEVEL                         = "info"
    ENVIRONMENT                       = "production"
    KAFKA_USERNAME                    = var.kafka_users.stockzrs_financial_aggregator_service.username
    KAFKA_PASSWORD                    = var.kafka_users.stockzrs_financial_aggregator_service.password
    KAFKA_TOPIC_RAW_FINANCIAL_UPDATES = var.kafka_topics.raw_financial_updates_topic
    KAFKA_TOPIC_MINUTE_AGGREGATES     = var.kafka_topics.minute_aggregates_topic
  })
}

resource "aws_secretsmanager_secret" "stockzrs_data_persistence_service_config" {
  name = "stockzrs-data-persistence-service-secrets"
}

resource "aws_secretsmanager_secret_version" "stockzrs_data_persistence_service_config" {
  secret_id = aws_secretsmanager_secret.stockzrs_data_persistence_service_config.id
  secret_string = jsonencode({
    KAFKA_BOOTSTRAP_SERVERS = var.kafka_bootstrap_server
    NODE_ENV                = "production"
    LOG_LEVEL               = "info"
    ENVIRONMENT             = "production"
    POSTGRES_HOST           = var.db_host
    POSTGRES_DB_NAME        = var.db_name
    POSTGRES_PORT           = var.db_port
    POSTGRES_USERNAME       = var.db_admin_username
    POSTGRES_PASSWORD       = var.db_admin_password
  })
}

resource "aws_secretsmanager_secret" "stockzrs_metrics_service_config" {
  name = "stockzrs-metrics-service-secrets"
}

resource "aws_secretsmanager_secret_version" "stockzrs_metrics_service_config" {
  secret_id = aws_secretsmanager_secret.stockzrs_metrics_service_config.id
  secret_string = jsonencode({
    PORT              = var.stockzrs_metrics_service_port
    LOG_LEVEL         = "info"
    ENVIRONMENT       = "production"
    POSTGRES_HOST     = var.db_host
    POSTGRES_DB_NAME  = var.db_name
    POSTGRES_PORT     = var.db_port
    POSTGRES_USERNAME = var.db_admin_username
    POSTGRES_PASSWORD = var.db_admin_password
  })
}
