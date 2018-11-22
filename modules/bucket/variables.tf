variable "name" {
  description = "The name of the bucket"
}

variable "data_retention_period_days" {
  description = "Specifies a period in the object's expire"
  default     = 90
}

# depends_on workaround

variable "depends_on" {
  type    = "list"
  default = []
}
