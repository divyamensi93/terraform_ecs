resource "aws_internet_gateway" "igw" {
  lifecycle { create_before_destroy = true }

  vpc_id = var.vpc_id
  tags   = var.tags
}

