# Mandatory:

variable "cidr_block" {
  type = string
}

variable "iam_log_role_arn" {
  type = string
}

variable "log_group_arn" {
  type = string
}

variable "tags" {
  type = map(string)
}
