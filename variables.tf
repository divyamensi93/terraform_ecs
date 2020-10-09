# main creds for AWS connection
variable "aws_access_key" {
  type    = string
  default = ""
}

variable "aws_secret_key" {
  type    = string
  default = ""
}

variable "ecs_cluster_name" {
  type    = string
  default = "luminor_assignment"
}

variable "vpc_log_group" {
  type    = string
  default = "luminor"
}


# Static:

variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "platform_cidr" {
  type    = string
  default = "10.0.0.0/16"
}


# Dynamic:

variable "ami_id" {
  type    = string
  default = ""
}

variable "environment" {
  type    = string
  default = "dev"
}


variable "services" {
  type    = string
  default = "Jenkins"
}
