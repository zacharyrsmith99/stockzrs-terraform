resource "aws_db_subnet_group" "stockzrs_db" {
  name       = "stockzrs-db-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name = "stockzrs_db subnet group"
  }
}

resource "aws_security_group" "postgres_sg" {
  name        = "stockzrs-db-security-group"
  description = "Security group for stockzrs_db RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "stockzrs_db access from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "stockzrs_db Security Group"
  }
}

resource "aws_db_instance" "stockzrs_db" {
  identifier             = "stockzrs-postgres"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "16.4"
  username               = "postgres"
  password               = var.stockzrs_db_password
  db_name                = "stockzrs"
  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  vpc_security_group_ids = [aws_security_group.postgres_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = {
    Name = "StockZRS PostgreSQL RDS"
  }
}