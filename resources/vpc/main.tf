resource "aws_vpc" "network" {
  lifecycle { create_before_destroy = true }

  assign_generated_ipv6_cidr_block = false
  cidr_block                       = var.cidr_block
  enable_classiclink               = false
  enable_classiclink_dns_support   = false
  enable_dns_hostnames             = true
  enable_dns_support               = true
  instance_tenancy                 = "default"
  tags                             = var.tags
}

resource "aws_default_route_table" "rt" {
  default_route_table_id = aws_vpc.network.default_route_table_id
  tags                   = merge(var.tags, { "Name" = format("%s-Main", var.tags["Name"]) })
}

resource "aws_flow_log" "fl" {
  iam_role_arn         = var.iam_log_role_arn
  log_destination      = var.log_group_arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.network.id
}
