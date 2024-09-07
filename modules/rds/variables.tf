resource "random_password" "stockzrs_db_password" {
  length  = 16
  special = false
}


variable "stockzrs_db_password" {
  default   = random_password.stockzrs_db_password
  sensitive = true
}