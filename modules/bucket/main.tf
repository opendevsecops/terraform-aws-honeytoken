resource "aws_s3_bucket" "main" {
  bucket = "${var.name}"
  acl    = "private"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::${var.name}"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.name}/*"
    }
  ]
}
EOF

  lifecycle_rule {
    id                                     = "Delete rule for all"
    enabled                                = true
    abort_incomplete_multipart_upload_days = 1

    expiration {
      days = "${var.data_retention_period_days}"
    }

    noncurrent_version_expiration {
      days = "${var.data_retention_period_days}"
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}
