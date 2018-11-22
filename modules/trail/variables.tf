variable "name" {
  description = "Specifies the name of the trail"

  default = "honeytoken"
}

variable "role_name" {
  description = "Specifies the role name for the CloudWatch Logs endpoint to assume to write to a user’s log group"

  default = "honeytoken"
}

variable "bucket_name" {
  description = "Specifies the name of the S3 bucket designated for publishing log files"
}

variable "bucket_key_prefix" {
  description = "Specifies the S3 key prefix that precedes the name of the bucket you have designated for log file delivery"
  default     = ""
}

# depends_on workaround

variable "depends_on" {
  type    = "list"
  default = []
}
