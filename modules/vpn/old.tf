
resource "aws_security_group" "vpn_access" {
  name_prefix = "vpn-access-"
  description = "Allow inbound traffic from VPN"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpn-access"
  }
}

resource "aws_ec2_client_vpn_network_association" "vpn_subnet_1" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_endpoint.id
  subnet_id              = aws_subnet.private_1.id
}

resource "aws_ec2_client_vpn_network_association" "vpn_subnet_2" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_endpoint.id
  subnet_id              = aws_subnet.private_2.id
}

resource "aws_ec2_client_vpn_authorization_rule" "vpn_auth_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_endpoint.id
  target_network_cidr    = aws_vpc.main.cidr_block
  authorize_all_groups   = true
}

resource "tls_private_key" "ca" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem = tls_private_key.ca.private_key_pem
  subject {
    common_name = "stockzrs.vpn.ca"
  }
  validity_period_hours = 87600
  is_ca_certificate     = true
  allowed_uses = [
    "cert_signing",
    "crl_signing"
  ]
}

resource "tls_private_key" "server" {
  algorithm = "RSA"
}

resource "tls_cert_request" "server" {
  private_key_pem = tls_private_key.server.private_key_pem
  subject {
    common_name = "stockzrs-vpn-server.com"
  }
}

resource "tls_locally_signed_cert" "server" {
  cert_request_pem      = tls_cert_request.server.cert_request_pem
  ca_private_key_pem    = tls_private_key.ca.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
  validity_period_hours = 87600
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]
}

resource "tls_private_key" "client" {
  for_each  = toset(var.aws-vpn-client-list)
  algorithm = "RSA"
}

resource "tls_cert_request" "client" {
  for_each        = toset(var.aws-vpn-client-list)
  private_key_pem = tls_private_key.client[each.key].private_key_pem
  subject {
    common_name = "stockzrs-vpn-${each.key}.com"
  }
}

resource "tls_locally_signed_cert" "client" {
  for_each              = toset(var.aws-vpn-client-list)
  cert_request_pem      = tls_cert_request.client[each.key].cert_request_pem
  ca_private_key_pem    = tls_private_key.ca.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
  validity_period_hours = 87600
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth"
  ]
}

resource "aws_acm_certificate" "vpn_server" {
  private_key       = tls_private_key.server.private_key_pem
  certificate_body  = tls_locally_signed_cert.server.cert_pem
  certificate_chain = tls_self_signed_cert.ca.cert_pem
}

resource "aws_acm_certificate" "vpn_client" {
  for_each          = toset(var.aws-vpn-client-list)
  private_key       = tls_private_key.client[each.key].private_key_pem
  certificate_body  = tls_locally_signed_cert.client[each.key].cert_pem
  certificate_chain = tls_self_signed_cert.ca.cert_pem
}

output "client_configurations" {
  value = {
    for client in var.aws-vpn-client-list :
    client => <<-EOF
      <cert>
      ${tls_locally_signed_cert.client[client].cert_pem}
      </cert>
      <key>
      ${tls_private_key.client[client].private_key_pem}
      </key>
    EOF
  }
  sensitive = true
}

resource "local_file" "vpn_config_file" {
  for_each = toset(var.aws-vpn-client-list)
  filename = "${path.module}/${each.key}-stockzrs-vpn.ovpn"
  content  = <<-EOT
    client
    dev tun
    proto udp
    remote ${aws_ec2_client_vpn_endpoint.vpn_endpoint.dns_name} 443
    remote-random-hostname
    resolv-retry infinite
    nobind
    remote-cert-tls server
    cipher AES-256-GCM
    verb 3
    <ca>
    ${tls_self_signed_cert.ca.cert_pem}
    </ca>
    <cert>
    ${tls_locally_signed_cert.client[each.key].cert_pem}
    </cert>
    <key>
    ${tls_private_key.client[each.key].private_key_pem}
    </key>
    EOT
}