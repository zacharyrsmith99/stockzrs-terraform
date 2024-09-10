output "ecr_repositories" {
  value = {
    stockzrs_relay = {
      name = aws_ecr_repository.stockzrs_relay_repository.name
      url  = aws_ecr_repository.stockzrs_relay_repository.repository_url
    },
    stockzrs_frontend = {
      name = aws_ecr_repository.stockzrs_frontend_repository.name
      url  = aws_ecr_repository.stockzrs_frontend_repository.repository_url
    }
  }
  description = "ECR repository details for Stockzrs services"
}

output "stockzrs_secrets_configs" {
  value = {
    stockzrs_relay = {
      arn           = aws_secretsmanager_secret.stockzrs_relay_config.arn
      secret_string = jsondecode(aws_secretsmanager_secret_version.stockzrs_relay_config.secret_string)
    }
    stockzrs_frontend = {
      arn           = aws_secretsmanager_secret.stockzrs_frontend_config.arn
      secret_string = jsondecode(aws_secretsmanager_secret_version.stockzrs_frontend_config.secret_string)
    }
    stockzrs_kafka = {
      arn           = aws_secretsmanager_secret.stockzrs_kafka_config.arn
      secret_string = jsondecode(aws_secretsmanager_secret_version.stockzrs_kafka_config.secret_string)
    }
  }
  sensitive = true
}