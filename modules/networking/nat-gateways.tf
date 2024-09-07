resource "aws_eip" "nat1" {
  domain = "vpc"

  tags = {
    Name = "nat-eip-1"
  }
}


resource "aws_nat_gateway" "gateway_1" {
  depends_on = [aws_internet_gateway.main]

  allocation_id = aws_eip.nat1.id
  subnet_id     = aws_subnet.public_1.id

  tags = {
    Name = "NAT-gateway-1"
  }
}