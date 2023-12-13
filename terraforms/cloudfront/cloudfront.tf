provider "aws" {
  region = "ap-northeast-2"
}

locals {
  s3_origin_id = "DailyOnFrontend"
}

resource "aws_s3_bucket" "frontend-s3" {
  bucket = "dailyon-frontend"

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}

resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = aws_s3_bucket.frontend-s3.id
  policy = data.aws_iam_policy_document.s3_policy_document.json
}

data "aws_iam_policy_document" "s3_policy_document" {

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.frontend-s3.arn}/*"]
    principals {
      type = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test = "StringEquals"
      variable = "AWS:SourceArn"
      values = [aws_cloudfront_distribution.frontend-cloudfront.arn]
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "s3-bucket-cors-config" {
  bucket = aws_s3_bucket.frontend-s3.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = [
      "x-amz-server-side-encryption",
      "x-amz-request-id",
      "x-amz-id-2"
    ]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_website_configuration" "s3_bucket_website_configuration" {
  bucket = aws_s3_bucket.frontend-s3.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_cloudfront_origin_access_identity" "cloudfront-access-identity" {
  comment = "This is a cloudfront distribution origin access identity"
}

resource "aws_cloudfront_distribution" "frontend-cloudfront" {
  origin {
    domain_name = aws_s3_bucket.frontend-s3.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_origin_access_control.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "DailyOn frontend CDN"
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}

resource "aws_cloudfront_origin_access_control" "cloudfront_origin_access_control" {
  name                              = "DailyonOriginAccessControl"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
