variable "aws_vpn_client_list" {
  type    = list(string)
  default = ["client1", "client2"]
}

variable "stockzrs_vpcs" {}
variable "stockzrs_subnets" {}
variable "aws_region" {}