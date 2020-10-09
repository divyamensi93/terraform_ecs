# Mandatory:

variable "route_tables" {
  type = list(string)
}


# Choose one:

variable "destination_cidr_block" {
  type    = string
  default = ""
}

variable "destination_ipv6_cidr_block" {
  type    = string
  default = ""
}


# Choose one:

variable "egress_only_gateways" {
  type    = list(string)
  default = [""]
}

variable "gateway_ids" { # Either internet gateway or virtual private gateway.
  type    = list(string)
  default = [""]
}

variable "instances" {
  type    = list(string)
  default = [""]
}

variable "nat_gateways" {
  type    = list(string)
  default = [""]
}

variable "network_interfaces" {
  type    = list(string)
  default = [""]
}

variable "transit_gateways" {
  type    = list(string)
  default = [""]
}

variable "vpc_peering_connections" {
  type    = list(string)
  default = [""]
}
