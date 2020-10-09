resource "aws_security_group" "sg" {
  lifecycle { create_before_destroy = true }

  dynamic "ingress" {
    for_each = var.rules
    content {
      cidr_blocks      = lookup(ingress.value, "cidr_blocks", null)
      description      = lookup(ingress.value, "description", null)
      from_port        = ingress.value.from_port
      protocol         = ingress.value.protocol
      to_port          = ingress.value.to_port
    }
  }
  name_prefix            = "${var.tags["Name"]}-${var.service}-"
  revoke_rules_on_delete = true
  vpc_id                 = var.vpc_id
  tags                   = merge(var.tags, { "Name" = "${var.tags["Name"]}-${var.service}" })
}

resource "aws_security_group_rule" "outbound" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.sg.id
  self              = false
  to_port           = 0
  type              = "egress"
}
