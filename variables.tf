variable "user_name" {
  description = "The name for the honeytoken user."
}

variable "user_path" {
  description = "Path in which to create the user."

  default = "/user/"
}

variable "trail_name" {
  description = "Specifies the name of the trail."

  default = "honeytoken"
}

variable "trail_bucket_name" {
  description = "Specifies the name of the S3 bucket designated for publishing log files."
}

variable "trail_bucket_key_prefix" {
  description = "Specifies the S3 key prefix that precedes the name of the bucket you have designated for log file delivery."

  default = ""
}

variable "lambda_name" {
  description = "A unique name for your Lambda Function."

  default = "honeytoken_cloudtrail_handler"
}

variable "lambda_role_name" {
  description = "A unique name for your Lambda Function."

  default = "honeytoken_cloudtrail_handler_role"
}