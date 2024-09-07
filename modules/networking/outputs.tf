output "stockzrs_subnets" {
  value = {
    private = [
      {
        id = aws_subnet.private_1.id
      },
      {
        id = aws_subnet.private_2.id
      },
    ]
    public = [
      {
        id = aws_subnet.public_1.id
      },
      {
        id = aws_subnet.public_2.id
      },
    ]
  }
}

output "stockzrs_vpcs" {
  value = {
    main = {
      id = aws_vpc.main.id
    }
  }
}