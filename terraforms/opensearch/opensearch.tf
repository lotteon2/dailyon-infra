provider "aws" {
  region = "ap-northeast-2"
}

data "aws_caller_identity" "current" {}

resource "aws_opensearch_domain" "open_search_domain" {
  domain_name    = "dailyon"
  engine_version = "OpenSearch_1.3"

  advanced_security_options {
    enabled                        = true
    anonymous_auth_enabled         = false
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = "root"
      master_user_password = "Dailyon12345!"
    }
  }

  cluster_config {
    instance_type = "t3.small.search"
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 20
  }

  node_to_node_encryption {
    enabled = true
  }

  encrypt_at_rest {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  access_policies = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "*"
        },
        "Action": "es:*",
        "Resource": "arn:aws:es:ap-northeast-2:${data.aws_caller_identity.current.account_id}:domain/dailyon/*"
      }
    ]
  }
  POLICY

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}
