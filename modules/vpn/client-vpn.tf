resource "aws_cloudwatch_log_group" "vpn_logs" {
  name              = "stockzrs/vpn/logs/"
  retention_in_days = 7
}
resource "aws_cloudwatch_log_stream" "vpn_logs_stream" {
  name           = "connection_logs"
  log_group_name = aws_cloudwatch_log_group.vpn_logs.name
}

resource "aws_ec2_client_vpn_endpoint" "vpn_client" {
  description            = "stockzrs-client-vpn"
  server_certificate_arn = aws_acm_certificate.server.arn
  client_cidr_block      = "172.16.0.0/16"
  dns_servers            = ["10.0.0.2"]
  split_tunnel           = true
  vpc_id                 = var.stockzrs_vpcs.main.id
  security_group_ids     = [aws_security_group.vpn_access.id]

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.server.arn
  }

  connection_log_options {
    enabled              = true
    cloudwatch_log_group = aws_cloudwatch_log_group.vpn_logs.name
  }

  tags = {
    Name      = "stockzrs-client-vpn"
    Terraform = "true"
  }
}

resource "aws_ec2_client_vpn_network_association" "vpn_client_1" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_client.id
  subnet_id              = var.stockzrs_subnets.private[0].id
}

resource "aws_ec2_client_vpn_network_association" "vpn_client_2" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_client.id
  subnet_id              = var.stockzrs_subnets.private[1].id
}

resource "aws_ec2_client_vpn_authorization_rule" "vpn-client" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_client.id
  target_network_cidr    = "0.0.0.0/0"
  authorize_all_groups   = true
  depends_on = [
    aws_ec2_client_vpn_endpoint.vpn_client,
    aws_ec2_client_vpn_network_association.vpn_client_1,
    aws_ec2_client_vpn_network_association.vpn_client_2
  ]
}


