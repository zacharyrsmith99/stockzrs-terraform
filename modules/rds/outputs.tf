output "db_endpoint" {
  value       = aws_db_instance.stockzrs_db.endpoint
}

output "db_host" {
  value       = split(":", aws_db_instance.stockzrs_db.endpoint)[0]
}

output "db_name" {
  value       = aws_db_instance.stockzrs_db.db_name
}

output "db_port" {
  value       = aws_db_instance.stockzrs_db.port
}

output "db_admin_username" {
  value       = aws_db_instance.stockzrs_db.username
}

output "db_admin_password" {
  value       = random_password.stockzrs_postgres_db_password.result
  sensitive   = true
}