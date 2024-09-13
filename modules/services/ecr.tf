resource "aws_ecr_repository" "stockzrs_relay_repository" {
  name                 = "stockzrs-relay-repository"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "stockzrs_frontend_repository" {
  name                 = "stockzrs-frontend-repository"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "stockzrs_financial_aggregator_service_repository" {
  name                 = "stockzrs-financial-aggregator-service-repository"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "stockzrs_data_persistence_service_repository" {
  name                 = "stockzrs-data-persistence-service-repository"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "stockzrs_metrics_service_repository" {
  name                 = "stockzrs-metrics-service-repository"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}


