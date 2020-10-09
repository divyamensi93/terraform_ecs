# Mandatory:

variable "service" { # Example: "Service-EC2"
  type = string
}

variable "vpc_id" {
  type = string
}

variable "tags" {
  type = map(string)
}


# Can be overriden:

variable "rules" {
  default = []
}

