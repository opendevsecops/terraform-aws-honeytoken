variable "name" {
  description = "A unique name for your Lambda Function."

  default = "honeytoken_cloudtrail_handler"
}

variable "role_name" {
  description = "A unique name for your Lambda Function."

  default = "honeytoken_cloudtrail_handler_role"
}

variable "log_group_arn" {
  description = "The arn for the log group to monitor."
}

variable "bucket_name" {
  description = "Specifies the name of the S3 bucket designated for publishing log files."
}

variable "bucket_key_prefix" {
  description = "Specifies the S3 key prefix that precedes the name of the bucket you have designated for log file delivery."
  default     = ""
}

variable "honey_user_name" {
  description = "The name of the honey user to monitor."
}

variable "notification_message" {
  description = "Notification message to send when threat identified"
  default     = "Danger, Will Robinson!"
}

variable "slack_notification_url" {
  description = "URL for slack notifications."
  default     = ""
}

# depends_on workaround

variable "depends_on" {
  type    = "list"
  default = []
}
