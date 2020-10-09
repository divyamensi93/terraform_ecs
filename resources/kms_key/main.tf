data "template_file" "kms_policy" {
  template = file("${path.module}/policies/KMS-${var.aws_service}-Access.json")

  vars = {
    aws_account_id = var.aws_account_id
    aws_service    = var.aws_service
    principals     = join("\",\"", var.principals)
    region         = var.region
  }
}

resource "aws_kms_key" "cmk" {
  lifecycle { create_before_destroy = true }

  deletion_window_in_days = var.tags["Environment"] == "Prod" ? 30 : 7
  enable_key_rotation     = var.enable_key_rotation
  is_enabled              = var.is_enabled
  key_usage               = var.key_usage
  policy                  = data.template_file.kms_policy.rendered
  tags                    = merge(var.tags, { "Name" = "${var.tags["Name"]}-${var.aws_service}" })
}

resource "aws_kms_alias" "cmk_name" {
  lifecycle { create_before_destroy = true }

  name_prefix   = "alias/${var.tags["Name"]}-${var.aws_service}-"
  target_key_id = aws_kms_key.cmk.key_id
}

