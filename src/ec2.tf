resource "aws_instance" "ec2_stockzrs_relay" {
  ami                    = "ami-0e36db3a3a535e401"
  instance_type          = "t4g.micro"
  vpc_security_group_ids = [aws_security_group.stockzrs_relay_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
              #!/bin/bash
              set -e

              yum update -y
              yum install -y git nodejs npm amazon-cloudwatch-agent

              npm install -g pm2

              git clone https://github.com/zacharyrsmith99/stockzrs-relay-service.git /home/ec2-user/stockzrs-relay-service
              chown -R ec2-user:ec2-user /home/ec2-user/stockzrs-relay-service

              # Configure CloudWatch agent
              cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<'EOT'
              {
                "agent": {
                  "run_as_user": "root"
                },
                "logs": {
                  "logs_collected": {
                    "files": {
                      "collect_list": [
                        {
                          "file_path": "/home/ec2-user/stockzrs-relay-service/app.log",
                          "log_group_name": "${aws_cloudwatch_log_group.stockzrs_relay.name}",
                          "log_stream_name": "{instance_id}",
                          "timezone": "UTC"
                        }
                      ]
                    }
                  }
                }
              }
              EOT

              /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

              systemctl enable amazon-cloudwatch-agent

              su - ec2-user << 'EOSU'
              cd /home/ec2-user/stockzrs-relay-service
              npm install
              SECRET_VALUE=$(aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.stockzrs_relay_config.id} --region us-east-1 --query SecretString --output text)
              cat << EOT > /home/ec2-user/set_env_vars.sh
              #!/bin/bash
              $(echo $SECRET_VALUE | jq -r 'to_entries[] | "export " + .key + "=\"" + .value + "\""')
              EOT
              chmod +x /home/ec2-user/set_env_vars.sh
              echo "source /home/ec2-user/set_env_vars.sh" >> /home/ec2-user/.bashrc
              source /home/ec2-user/set_env_vars.sh
              pm2 start npm --name "stockzrs-relay" -- start
              pm2 save
              pm2 startup systemd -u ec2-user --hp /home/ec2-user
              EOSU

              # Set PM2 to start on boot
              env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ec2-user --hp /home/ec2-user
              EOF
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