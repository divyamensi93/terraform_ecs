data "template_file" "assume_role_policy" {
  template = file("${path.module}/policies/Principal.json")

  vars = {
    principal  = var.principal
    principals = var.principals
  }
}

resource "aws_iam_role" "r" {
  lifecycle { create_before_destroy = true }

  assume_role_policy    = data.template_file.assume_role_policy.rendered
  force_detach_policies = true
  max_session_duration  = 3600
  name_prefix           = "${var.tags["Name"]}-${var.service}-"
  path                  = var.path
  tags                  = merge(var.tags, { "Name" = "${var.tags["Name"]}-${var.service}" })
}

resource "aws_iam_instance_profile" "ip" {
  lifecycle { create_before_destroy = true }

  name_prefix = "${var.tags["Name"]}-${var.service}-Profile-"
  path        = var.path
  role        = aws_iam_role.r.name
}

data "template_file" "ecr-pull-resources" {
  count    = length(var.ecr_repositories) > 0 ? length(var.ecr_repositories) : 1
  template = "arn:aws:ecr:$${region}:$${aws_account_id}:repository/$${repository}"

  vars = {
    aws_account_id = lower(var.aws_account_id)
    region         = lower(var.region)
    repository     = length(var.ecr_repositories) > 0 ? lower(var.ecr_repositories[count.index]) : lower(var.service)
  }
}

data "template_file" "policies" {
  count    = length(var.policies)
  template = file("${path.module}/policies/${var.policies[count.index]}.json")

  vars = {
    aws_account_id = lower(var.aws_account_id)
    region         = lower(var.region)
    environment    = lower(var.tags["Environment"])
    service        = lower(var.service)
    resource       = join("\",\"", data.template_file.ecr-pull-resources.*.rendered)
  }
}

locals {
  policies_tokenized = data.template_file.policies.*.rendered
}

resource "aws_iam_role_policy" "inline" {
  lifecycle { create_before_destroy = true }

  count       = length(local.policies_tokenized)
  name_prefix = "${var.policies[count.index]}-"
  policy      = local.policies_tokenized[count.index]
  role        = aws_iam_role.r.id
}

