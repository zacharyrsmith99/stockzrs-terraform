resource "aws_ecr_repository" "stockzrs_relay_repository" {
  name                 = "stockzrs-relay-repository"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

