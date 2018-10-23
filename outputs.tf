output "user_name" {
  value = "${module.user.name}"
}

output "user_path" {
  value = "${module.user.path}"
}

output "user_access_key_id" {
  value = "${element(module.user.access_key_ids, 0)}"
}

output "user_access_key_secret" {
  value = "${element(module.user.access_key_secrets, 0)}"
}
