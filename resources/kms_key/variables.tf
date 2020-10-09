# Mandatory:

variable "aws_account_id" {
  type = string
}

variable "aws_service" { # Expected values: EBS or RDS
  type = string
}

variable "region" {
  type = string
}

variable "principals" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}


# Can be overriden:

variable "deletion_window_in_days" {
  type    = string
  default = "7"
}

variable "enable_key_rotation" {
  type    = string
  default = "true"
}

variable "is_enabled" {
  type    = string
  default = "true"
}

variable "key_usage" {
  type    = string
  default = "ENCRYPT_DECRYPT"
}
