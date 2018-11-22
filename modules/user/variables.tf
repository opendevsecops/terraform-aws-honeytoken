variable "name" {
  description = "The name for the user"
}

variable "path" {
  description = "Path in which to create the user"

  default = "/"
}

variable "tokens" {
  description = "Number of tokens to generate"

  default = 1
}

# depends_on workaround

variable "depends_on" {
  type    = "list"
  default = []
}
