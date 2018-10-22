resource "aws_iam_user" "user" {
  name = "${var.name}"
  path = "${var.path}"
}

resource "aws_iam_access_key" "access_key" {
  count = "${var.tokens}"
  user  = "${aws_iam_user.user.name}"
}
