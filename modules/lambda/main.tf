data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  source_dir           = "${path.module}/src/"
  output_path          = "${path.module}/build/lambda.zip"
  timeout              = 900
  log_retention_period = 90
}

data "archive_file" "main" {
  type        = "zip"
  source_dir  = "${local.source_dir}"
  output_path = "${local.output_path}"
}

resource "aws_lambda_function" "main" {
  function_name    = "${var.name}"
  handler          = "index.handler"
  runtime          = "nodejs8.10"
  filename         = "${local.output_path}"
  source_code_hash = "${data.archive_file.main.output_base64sha256}"
  role             = "${aws_iam_role.main.arn}"
  timeout          = "${local.timeout}"

  environment {
    variables = {
      HONEYUSERNAME          = "${var.honey_user_name}"
      NOTIFICATION_MESSAGE   = "${var.notification_message}"
      SLACK_NOTIFICATION_URL = "${var.slack_notification_url}"
    }
  }
}

resource "aws_iam_role" "main" {
  name = "${var.role_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "main_policy" {
  name = "logs"
  role = "${aws_iam_role.main.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup"
      ],
      "Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::${var.bucket_name}${var.bucket_key_prefix == "" ?  "/" : "/${var.bucket_key_prefix}/"}*"
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = "${local.log_retention_period}"
}

resource "aws_lambda_permission" "main" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.main.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.bucket_name}"
}

resource "aws_s3_bucket_notification" "main" {
  bucket = "${var.bucket_name}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.main.arn}"
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "${var.bucket_key_prefix}"
  }
}
