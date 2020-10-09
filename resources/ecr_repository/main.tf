resource "aws_ecr_repository" "registry" {
  lifecycle { create_before_destroy = true }

  count = var.services[0] != "" ? length(var.services) : 0
  name  = lower("${var.tags["Name"]}-${var.services[count.index]}")
  tags  = merge(var.tags, { "Name" = "${var.tags["Name"]}-${var.services[count.index]}" })
}

data "null_data_source" "ecr_urls" {
  count = var.services[0] != "" ? length(var.services) : 0
  inputs = {
    service = var.services[count.index]
    url     = aws_ecr_repository.registry[count.index].repository_url
  }
}
