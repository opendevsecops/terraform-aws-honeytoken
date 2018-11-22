data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

module "lambda" {
  source  = "opendevsecops/lambda/aws"
  version = "0.3.0"

  source_dir  = "${path.module}/src"
  output_path = "${path.module}/build/lambda.zip"

  name      = "${var.name}"
  role_name = "${var.role_name}"

  timeout               = 900
  log_retention_in_days = 90

  environment {
    HONEYUSERNAME          = "${var.honey_user_name}"
    NOTIFICATION_MESSAGE   = "${var.notification_message}"
    IP_WHITELIST           = "${join(",", var.ip_whitelist)}"
    USER_AGENT_WHITELIST   = "${join("|", var.user_agent_whitelist)}"
    SLACK_NOTIFICATION_URL = "${var.slack_notification_url}"
  }
}

resource "aws_iam_role_policy" "policy" {
  role = "${module.lambda.role_name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
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

  depends_on = ["module.lambda"]
}

resource "aws_lambda_permission" "main" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${module.lambda.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.bucket_name}"

  depends_on = ["module.lambda"]
}

resource "aws_s3_bucket_notification" "main" {
  bucket = "${var.bucket_name}"

  lambda_function {
    lambda_function_arn = "${module.lambda.arn}"
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "${var.bucket_key_prefix}"
  }

  depends_on = ["module.lambda"]
}
