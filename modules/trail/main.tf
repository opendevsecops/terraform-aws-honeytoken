data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  log_retention_period = 90
}

resource "aws_cloudwatch_log_group" "main" {
  name              = "/cloudtrail/${var.name}"
  retention_in_days = "${local.log_retention_period}"
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
				"Service": "cloudtrail.amazonaws.com"
			},
			"Effect": "Allow"
		}
	]
}
EOF
}

resource "aws_iam_role_policy" "main" {
  name = "main"
  role = "${aws_iam_role.main.id}"

  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Action": [
				"logs:CreateLogStream",
				"logs:PutLogEvents"
			],
			"Effect": "Allow",
			"Resource": "${aws_cloudwatch_log_group.main.arn}"
		}
	]
}
EOF
}

resource "aws_cloudtrail" "trail" {
  name = "${var.name}"

  s3_bucket_name = "${var.bucket_name}"
  s3_key_prefix  = "${var.bucket_key_prefix}"

  cloud_watch_logs_role_arn  = "${aws_iam_role.main.arn}"
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.main.arn}"

  is_multi_region_trail = true

  enable_logging = true
}
