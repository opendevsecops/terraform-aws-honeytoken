output "name" {
  value = "${var.name}"
}

output "path" {
  value = "${var.path}"
}

output "access_key_ids" {
  value = ["${aws_iam_access_key.access_key.*.id}"]
}

output "access_key_secrets" {
  value = ["${aws_iam_access_key.access_key.*.secret}"]
}
