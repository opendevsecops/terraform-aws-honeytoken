module "user" {
  source = "modules/user"

  name   = "${var.user_name}"
  path   = "${var.user_path}"
  tokens = 1
}

module "bucket" {
  source = "modules/bucket"

  name = "${var.trail_bucket_name}"
}

module "trail" {
  source = "modules/trail"

  name              = "${var.trail_name}"
  bucket_name       = "${var.trail_bucket_name}"
  bucket_key_prefix = "${var.trail_bucket_key_prefix}"

  depends_on = ["${module.bucket.name}"]
}

module "handler" {
  source = "modules/handler"

  name                   = "${var.handler_name}"
  role_name              = "${var.handler_role_name}"
  bucket_name            = "${var.trail_bucket_name}"
  bucket_key_prefix      = "${var.trail_bucket_key_prefix}"
  honey_user_name        = "${var.user_name}"
  ip_whitelist           = "${var.ip_whitelist}"
  user_agent_whitelist   = "${var.user_agent_whitelist}"
  slack_notification_url = "${var.slack_notification_url}"

  depends_on = ["${module.bucket.name}", "${module.trail.name}"]
}
