terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "github" {
  token = var.github_token
}