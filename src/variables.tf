variable "region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t4g.micro"
}

variable "linux_ami_id" {
  default = "ami-0ae8f15ae66fe8cda"
}

variable "stockzrs_relay_port" {
  type    = number
  default = 80
}

variable "stockzrs_relay_github_repository" {
  default = "stockzrs-relay-service"
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