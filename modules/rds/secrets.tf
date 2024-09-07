resource "aws_secretsmanager_secret" "stockzrs_postgres_db" {
  name = "stockzrs-postgres-secrets1"
}

resource "aws_secretsmanager_secret_version" "stockzrs_frontend_config" {
  secret_id = aws_secretsmanager_secret.stockzrs_postgres_db.id
  secret_string = jsonencode({
    ENDPOINT       = aws_db_instance.stockzrs_db.endpoint
    DB_NAME        = aws_db_instance.stockzrs_db.db_name
    PORT           = aws_db_instance.stockzrs_db.port
    DOMAIN         = aws_db_instance.stockzrs_db.domain
    ADMIN_USERNAME = aws_db_instance.stockzrs_db.username
    ADMIN_PASSWORD = var.stockzrs_db_password
  })
}
