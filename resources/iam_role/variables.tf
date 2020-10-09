#mandatory:

variable "policies" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}


# Choose ones needed for principals or instance profiles:

variable "aws_account_id" {
  type    = string
  default = ""
}

variable "ecr_repositories" {
  type    = list(string)
  default = []
}

variable "path" { # Must have trailing slash. Don't change, unless we rearchitecture whole IAM structure.
  type    = string
  default = "/"
}

variable "principal" {
  type    = string
  default = "Service"
}

variable "principals" {
  type    = string
  default = "ec2.amazonaws.com"
}

variable "region" {
  type    = string
  default = ""
}

variable "service" {
  type    = string
  default = ""
}
