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

