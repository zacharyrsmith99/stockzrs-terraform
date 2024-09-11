variable "stockzrs_secrets_configs" {}
variable "stockzrs_subnets" {}
variable "stockzrs_vpcs" {}
variable "kafka_raw_financial_updates_topic" {
  default = "raw-financial-updates"
}
variable "kafka_minute_aggregates_topic" {
  default = "minute-aggregated-financial-updates"
}