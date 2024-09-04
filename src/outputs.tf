output "secret_arn" {
  value = aws_secretsmanager_secret.stockzrs_relay_config.arn
}

output "ecr_repository_url" {
  value = aws_ecr_repository.stockzrs_relay_repository.repository_url
}