variable "region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t4g.micro"
}

variable "linux_ami_id" {
  default = "ami-0ae8f15ae66fe8cda"
}

variable "stockzrs_port" {
  type    = number
  default = 8000
}