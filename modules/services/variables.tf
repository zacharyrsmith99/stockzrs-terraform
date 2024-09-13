variable "twelvedata_api_key" {
  type      = string
  sensitive = true
}

variable "coinbase_api_key" {
  type      = string
  sensitive = true
}

variable "coinbase_api_private_key" {
  type      = string
  sensitive = true
}

variable "stockzrs_relay_service_ws_url" {
  default = "wss://stockzrs-relay-service.stockzrs.com"
}

variable "stockzrs_frontend_port" {}

variable "stockzrs_relay_port" {}

variable "kafka_bootstrap_server" {}

variable "kafka_topics" {}

variable "kafka_users" {}

## db #####################
variable "db_host" {}
variable "db_name" {}
variable "db_port" {}
variable "db_admin_username" {}
variable "db_admin_password" {}
########################

variable "stockzrs_metrics_service_port" {}

