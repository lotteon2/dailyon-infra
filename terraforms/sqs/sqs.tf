provider "aws" {
  region = "ap-northeast-2"
}

data "aws_caller_identity" "current" {}

# Define the SQS queue
resource "aws_sqs_queue" "notification_queue" {
  name                       = "notificationQueue"
  delay_seconds              = 0
  max_message_size           = 2048
  message_retention_seconds  = 345600
  visibility_timeout_seconds = 30
}

resource "aws_sqs_queue_policy" "sqs_policy" {
  queue_url = aws_sqs_queue.notification_queue.id
  policy    = data.aws_iam_policy_document.sqs_policy_document.json
}

data "aws_iam_policy_document" "sqs_policy_document" {
  statement {
    sid    = "sqs_policy"
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["sqs:*"]
    resources = [aws_sqs_queue.notification_queue.arn]
  }
}
