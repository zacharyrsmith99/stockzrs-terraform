resource "aws_secretsmanager_secret" "stockzrs_postgres_db" {
  name = "stockzrs-postgres-secrets"
}

resource "aws_secretsmanager_secret_version" "stockzrs_postgres_config" {
  secret_id = aws_secretsmanager_secret.stockzrs_postgres_db.id
  secret_string = jsonencode({
    ENDPOINT       = aws_db_instance.stockzrs_db.endpoint
    DB_NAME        = aws_db_instance.stockzrs_db.db_name
    PORT           = aws_db_instance.stockzrs_db.port
    ADMIN_USERNAME = aws_db_instance.stockzrs_db.username
    ADMIN_PASSWORD = random_password.stockzrs_postgres_db_password.result
  })
}
