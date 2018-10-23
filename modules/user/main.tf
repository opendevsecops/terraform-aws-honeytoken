resource "aws_iam_user" "user" {
  name = "${var.name}"
  path = "${var.path}"
}

resource "aws_iam_user_policy" "policy" {
  user = "${aws_iam_user.user.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_access_key" "access_key" {
  user  = "${aws_iam_user.user.name}"
  count = "${var.tokens}"
}
