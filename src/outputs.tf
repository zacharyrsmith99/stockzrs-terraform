output "stockzrs_relay_public_ip" {
  value       = aws_eip.stockzrs_relay_ip.public_ip
}

output "secret_arn" {
  value       = aws_secretsmanager_secret.stockzrs_relay_config.arn
}
