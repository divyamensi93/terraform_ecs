data "aws_availability_zones" "vpc_region" {}

resource "aws_subnet" "sizing" {
  count                   = var.amount
  availability_zone       = data.aws_availability_zones.vpc_region.names[count.index]
  cidr_block              = cidrsubnet(var.vpc_cidr_block, var.vpc_cidr_increment, count.index + 1)
  map_public_ip_on_launch = var.map_public_ip_on_launch
  vpc_id                  = var.vpc_id
  tags                    = merge(var.tags, { "Name" = format("%s-%s-%s", var.tags["Name"], var.map_public_ip_on_launch ? "Public" : "Private", upper(substr(data.aws_availability_zones.vpc_region.names[count.index], -1, 1))) })
}

resource "aws_route_table" "rt" {
  lifecycle { create_before_destroy = true }

  count  = var.amount
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { "Name" = format("%s-%s-%s", var.tags["Name"], var.map_public_ip_on_launch ? "Public" : "Private", upper(substr(data.aws_availability_zones.vpc_region.names[count.index], -1, 1))) })
}

locals {
  route_tables = aws_route_table.rt.*.id
  subnets      = aws_subnet.sizing.*.id
}

resource "aws_route_table_association" "rta" {
  count          = var.amount
  route_table_id = local.route_tables[count.index]
  subnet_id      = local.subnets[count.index]
}

