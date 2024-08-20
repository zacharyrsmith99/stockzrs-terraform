output "stockzrs_relay_public_ip" {
  value       = aws_eip.stockzrs_relay_ip.public_ip
  description = "The public IP address of the EC2 instance"
}

output "secret_arn" {
  value       = aws_secretsmanager_secret.stockzrs_relay_config.arn
  description = "The ARN of the Secrets Manager secret"
}
