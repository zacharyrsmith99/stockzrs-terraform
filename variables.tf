variable "region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t4g.micro"
}

variable "stockzrs_relay_github_repository" {
  default = "stockzrs-relay-service"
}

variable "stockzrs_frontend_github_repository" {
  default = "stockzrs-frontend"
}

variable "github_repositories_with_common_secrets" {
  type        = list(string)
  description = "List of GitHub repositories to set secrets for"
  default     = ["stockzrs-relay-service", "stockzrs-frontend"]
}

variable "stockzrs_frontend_port" {
  type    = number
  default = 8000
}

variable "stockzrs_relay_port" {
  type    = number
  default = 80
}

variable "aws_region" {
  default = "us-east-1"
}

variable "github_token" {
  type      = string
  sensitive = true
}

variable "cidr_blocks_ssh" {
  type      = string
  sensitive = true
}

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

variable "ingress_nginx_lb_hosted_zone_id" {
  type = string
  sensitive = true
}