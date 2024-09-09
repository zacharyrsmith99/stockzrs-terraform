resource "aws_instance" "openvpn" {
  ami           = "ami-06e5a963b2dadea6f"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.openvpn.id]
  subnet_id              = var.stockzrs_subnets.public[0].id

  associate_public_ip_address = true

  tags = {
    Name = "OpenVPN-Server"
  }
}

resource "aws_eip" "openvpn" {
  instance = aws_instance.openvpn.id
  domain   = "vpc"
}


resource "aws_security_group" "openvpn" {
  name        = "openvpn-security-group"
  description = "Security group for OpenVPN server"
  vpc_id      = var.stockzrs_vpcs.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 943
    to_port     = 943
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 945
    to_port     = 945
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ec2_instance_connect" {
  name = "ec2-instance-connect-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_instance_connect" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceConnect"
  role       = aws_iam_role.ec2_instance_connect.name
}

resource "aws_iam_instance_profile" "ec2_instance_connect" {
  name = "ec2-instance-connect-profile"
  role = aws_iam_role.ec2_instance_connect.name
}

resource "aws_security_group_rule" "allow_ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = [var.ssh_connect_cidr_block]
  security_group_id = aws_security_group.openvpn.id
}