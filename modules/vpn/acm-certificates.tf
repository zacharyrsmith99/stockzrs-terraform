####### CA
resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = 2048
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
    "crl_signing",
  ]
}

resource "aws_acm_certificate" "ca" {
  private_key      = tls_private_key.ca.private_key_pem
  certificate_body = tls_self_signed_cert.ca.cert_pem
  tags = {
    Terraform = "true"
  }
}

resource "aws_ssm_parameter" "vpn_ca_key" {
  name        = "/stockzrs/acm/vpn/ca_key"
  description = "VPN CA key"
  type        = "SecureString"
  value       = tls_private_key.ca.private_key_pem

  tags = {
    Terraform = "true"
  }
}
resource "aws_ssm_parameter" "vpn_ca_cert" {
  name        = "/stockzrs/acm/vpn/ca_cert"
  description = "VPN CA cert"
  type        = "SecureString"
  value       = tls_self_signed_cert.ca.cert_pem
  tags = {
    Terraform = "true"
  }
}

############ CERT SERVER

resource "aws_acm_certificate" "server" {
  private_key       = tls_private_key.server.private_key_pem
  certificate_body  = tls_locally_signed_cert.server.cert_pem
  certificate_chain = tls_self_signed_cert.ca.cert_pem
  tags = {
    Terraform = "true"
  }
}

resource "tls_private_key" "server" {
  algorithm = "RSA"
}

resource "tls_cert_request" "server" {
  private_key_pem = tls_private_key.server.private_key_pem
  subject {
    common_name = "stockzrs.vpn.server"
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
    "server_auth",
  ]
}

resource "aws_ssm_parameter" "vpn_server_key" {
  name        = "/stockzrs/acm/vpn/server_key"
  description = "Stockzrs VPN server key"
  type        = "SecureString"
  value       = tls_private_key.server.private_key_pem
  tags = {
    Terraform = "true"
  }
}

resource "aws_ssm_parameter" "vpn_server_cert" {
  name        = "/stockzrs/acm/vpn/server_cert"
  description = "VPN server cert"
  type        = "SecureString"
  value       = tls_locally_signed_cert.server.cert_pem
  tags = {
    Terraform = "true"
  }
}