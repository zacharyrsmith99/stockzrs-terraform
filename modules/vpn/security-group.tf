resource "aws_security_group" "vpn_access" {
  name        = "stockzrs-vpn-security-group"
  description = "stockzrs-vpn-security-group"
  vpc_id      = var.stockzrs_vpcs.main.id
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
    Name = "stockzrs-vpn-security-group"
  }
}