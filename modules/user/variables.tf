variable "name" {
  description = "The name for the user."
}

variable "path" {
  description = "Path in which to create the user."

  default = "/user/"
}

variable "tokens" {
  description = "Number of tokens to generate."

  default = 0
}
