output "name" {
  value = "${var.name}"
}

output "log_group_arn" {
  value = "${aws_cloudwatch_log_group.main.arn}"
}
