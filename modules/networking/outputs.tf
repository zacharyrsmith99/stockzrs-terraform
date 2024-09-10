output "stockzrs_subnets" {
  value = {
    private = [
      {
        id                = aws_subnet.private_1.id
        availability_zone = aws_subnet.private_1.availability_zone
      },
      {
        id                = aws_subnet.private_2.id
        availability_zone = aws_subnet.private_2.availability_zone
      },
    ],
    public = [
      {
        id                = aws_subnet.public_1.id
        availability_zone = aws_subnet.public_1.availability_zone
      },
      {
        id                = aws_subnet.public_2.id
        availability_zone = aws_subnet.public_2.availability_zone
      },
    ]
    rds_private = [
      {
        id                = aws_subnet.rds_1.id
        availability_zone = aws_subnet.rds_1.availability_zone
      },
      {
        id                = aws_subnet.rds_2.id
        availability_zone = aws_subnet.rds_2.availability_zone
      },
    ]
  }
}

output "stockzrs_vpcs" {
  value = {
    main = {
      id         = aws_vpc.main.id
      cidr_block = aws_vpc.main.cidr_block
    }
  }
}