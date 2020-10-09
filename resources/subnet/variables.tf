# Mandatory:

variable "vpc_cidr_block" {
  type = string
}

variable "vpc_cidr_increment" { # How many bytes should be added to the VPCs CIDR range. Example: Initial /23 + vpc_cidr_increment 4 = /27 subnets.
  type = string
}

variable "vpc_id" {
  type = string
}

variable "tags" {
  type = map(string)
}


# Can be overriden:

variable "amount" {
  type    = string
  default = "1"
}

variable "map_public_ip_on_launch" {
  type    = string
  default = false
}

