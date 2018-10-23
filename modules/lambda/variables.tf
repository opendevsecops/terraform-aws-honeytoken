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

# depends_on workaround

variable "depends_on" {
  type    = "list"
  default = []
}
