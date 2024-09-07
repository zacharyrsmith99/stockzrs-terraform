resource "aws_cloudwatch_log_group" "vpn_log_group" {
  name              = "/aws/vpn/stockzrs-client-vpn"
  retention_in_days = 7
}

resource "aws_ec2_client_vpn_endpoint" "vpn_endpoint" {
  description            = "stockzrs-client-vpn"
  server_certificate_arn = aws_acm_certificate.vpn_server.arn
  client_cidr_block      = var.client_cidr_block
  dns_servers            = ["10.0.0.2"]
  split_tunnel           = true
  vpc_id                 = aws_vpc.main.id
  security_group_ids     = [aws_security_group.vpn_access.id]

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.vpn_server.arn
  }

  connection_log_options {
    enabled              = true
    cloudwatch_log_group = aws_cloudwatch_log_group.vpn_log_group.name
  }

  tags = {
    Name = "stockzrs-client-vpn"
  }
}


