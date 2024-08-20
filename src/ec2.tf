resource "aws_instance" "ec2_stockzrs_relay" {
  ami                    = "ami-0e36db3a3a535e401"
  instance_type          = "t4g.micro"
  vpc_security_group_ids = [aws_security_group.stockzrs_relay_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
}

resource "aws_security_group" "stockzrs_relay_sg" {
  name        = "stockzrs_relay_sg"
  description = "Security group for Stockzrs Relay service"

  ingress {
    description = "Application port"
    from_port   = var.stockzrs_port
    to_port     = var.stockzrs_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from EC2 Instance Connect"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["18.206.107.24/29"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "stockzrs_relay_ip" {
  instance = aws_instance.ec2_stockzrs_relay.id
  domain   = "vpc"
}

output "public_ip" {
  value = aws_eip.stockzrs_relay_ip.public_ip
}