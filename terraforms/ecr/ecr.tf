provider "aws" {
  region = "ap-northeast-2"
}

variable "ecr_repos" {
  type    = list(string)
  default = [
    "dailyon-wish-cart-service",
    "dailyon-sns-service",
    "dailyon-review-service",
    "dailyon-promotion-service",
    "dailyon-product-service",
    "dailyon-payment-service",
    "dailyon-order-service",
    "dailyon-notification-service",
    "dailyon-member-service",
    "dailyon-discovery-service",
    "dailyon-config-service",
    "dailyon-auth-service",
    "dailyon-auction-service",
    "dailyon-search-service",
    "dailyon-apigateway-service"
  ]
}

resource "aws_ecr_repository" "ecr_repositories" {
  count = length(var.ecr_repos)

  name = var.ecr_repos[count.index]

  image_scanning_configuration {
    scan_on_push = false
  }

  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_lifecycle_policy" "my_ecr_repo_lifecycle_policy" {
  count = length(var.ecr_repos)

  repository = aws_ecr_repository.ecr_repositories[count.index].name

  policy = <<EOF
  {
      "rules": [
          {
              "rulePriority": 1,
              "description": "Expire images older than 30 days",
              "selection": {
                  "tagStatus": "any",
                  "countType": "sinceImagePushed",
                  "countUnit": "days",
                  "countNumber": 30
              },
              "action": {
                  "type": "expire"
              }
          }
      ]
  }
  EOF
}