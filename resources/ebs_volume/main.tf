data "aws_availability_zones" "vpc_region" {}

resource "aws_ebs_volume" "drive" {
  lifecycle { create_before_destroy = true }

  availability_zone = data.aws_availability_zones.vpc_region.names[var.az_index]
  encrypted         = var.encrypted
  iops              = var.iops
  kms_key_id        = var.kms_key_id
  size              = var.size
  snapshot_id       = var.snapshot_id
  type              = var.iops != "0" ? "io1" : "gp2"
  tags              = merge(var.tags, { "Name" = "${var.tags["Name"]}-Encrypted-Volume-${upper(substr(data.aws_availability_zones.vpc_region.names[var.az_index], -1, 1))}" })
}

