# Mandatory:

variable "aws_account_id" {
  type = string
}

variable "region" {
  type = string
}

variable "tags" {
  type = map(string)
}


# Can be overriden:

variable "az_index" { # Availability zone index: 0 - A, 1 - B, 2 - C
  type    = string
  default = "0"
}

variable "encrypted" {
  type    = string
  default = "true"
}

variable "iops" { # Usage: io1 - up to 50 IOPS per 1 GB with maximum 64000 IOPS
  type    = string
  default = "0"
}

variable "kms_key_id" {
  type    = string
  default = ""
}

variable "size" {
  type    = string
  default = "20"
}

variable "snapshot_id" {
  type    = string
  default = ""
}

variable "type" {
  type    = string
  default = "gp2"
}
