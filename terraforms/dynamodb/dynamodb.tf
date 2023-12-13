provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_dynamodb_table" "dynamodb-order" {
  name           = "orders"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "member_id"
    type = "N"
  }

  attribute {
    name = "created_at"
    type = "S"
  }

  global_secondary_index {
    name               = "memberIndex"
    hash_key           = "member_id"
    range_key          = "created_at"
    projection_type    = "INCLUDE"
    non_key_attributes = ["id"]
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}