resource "null_resource" "dependency" {
  triggers = {
    depends_on = join(",", var.dependencies)
  }
}

resource "tls_private_key" "pk" {
  lifecycle { create_before_destroy = true }

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  lifecycle { create_before_destroy = true }

  key_name_prefix = "Luminor-${var.tags["Environment"]}-var.service-"
  public_key      = tls_private_key.pk.public_key_openssh
}


data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["591542846629"]

  filter {
    name   = "name"
    values = ["*amazon-ecs-optimized"]
  }
}

data "aws_ami" "current_id_os" {
  owners = [var.ami_id != "" ? "self" : "591542846629"]

  filter {
    name   = "image-id"
    values = [var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id]
  }
}

data "template_file" "service-user-data" {
  template = file("${path.module}/../../services/${var.service}/user-data.sh")

  vars = merge({
    aws_account_id   = var.aws_account_id
    aws_region       = var.aws_region
    ecs_cluster_name = var.ecs_cluster_name
    environment      = lower(var.tags["Environment"])
    service          = lower(var.service)
  }, var.user_data_additional_vars)
}

locals {
  ebs_devices   = [for device in var.block_devices: device if lookup(device, "root_device", null) == null]
  root_device   = [for device in var.block_devices: device if lookup(device, "root_device", null) != null]
}

data "template_file" "used_drive_letters" {
  count    = length(var.block_devices)
  template = "$${letter}"

  vars = {
    letter = lookup(var.block_devices[count.index], "device_name", null) != null && var.block_devices[count.index] != 0 ? regex("[a-z]$",lookup(var.block_devices[count.index], "device_name")) : ""
  }
}

locals {
  drive_letters = [for letter in var.drive_letters: letter if !contains(compact(data.template_file.used_drive_letters.*.rendered), letter)]
}

resource "aws_launch_configuration" "lc" {
  lifecycle { create_before_destroy = true }

  count                = var.asg_type == "launch_configuration" ? 1 : 0
  ebs_optimized        = ! contains(var.unoptimized_ebs_ec2s, var.instance_type)
  iam_instance_profile = var.iam_profile
  image_id             = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id
  instance_type        = var.instance_type
  key_name             = aws_key_pair.kp.key_name
  name_prefix          = "${var.tags["Name"]}-var.service"
  security_groups      = var.security_groups
  user_data            = data.template_file.service-user-data.rendered

  dynamic "root_block_device" {
    for_each = local.root_device
    content {
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", true)
      encrypted             = lookup(root_block_device.value, "encrypted", true)
      iops                  = lookup(root_block_device.value, "iops", 0)
      volume_size           = lookup(root_block_device.value, "volume_size", 30)
      volume_type           = lookup(root_block_device.value, "volume_type", "gp2")
    }
  }
  dynamic "ebs_block_device" {
    for_each = local.ebs_devices
    content {
      device_name           = lookup(ebs_block_device.value, "device_name", "/dev/xvd${local.drive_letters[ebs_block_device.key]}")
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", true)
      encrypted             = lookup(ebs_block_device.value, "encrypted", true)
      iops                  = lookup(ebs_block_device.value, "iops", 0)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", 20)
      volume_type           = lookup(ebs_block_device.value, "volume_type", "gp2")
    }
  }
}

data "null_data_source" "asg-tags" {
  count = length(keys(merge(var.tags, { "Client" = var.client }, { "Name" = "${var.tags["Name"]}-${var.service}" })))

  inputs = {
    key                 = element(keys(merge(var.tags, { "Client" = var.client }, { "Name" = "${var.tags["Name"]}-${var.service}" })), count.index)
    value               = element(values(merge(var.tags, { "Client" = var.client }, { "Name" = "${var.tags["Name"]}-${var.service}" })), count.index)
    propagate_at_launch = "true"
  }
}

resource "aws_autoscaling_group" "asg" {
  lifecycle { create_before_destroy = true }
  depends_on = [null_resource.dependency]

  default_cooldown          = var.asg_cooldown
  desired_capacity          = var.instance_count
  enabled_metrics           = var.asg_metrics
  force_delete              = false
  health_check_grace_period = var.asg_grace_period
  health_check_type         = var.load_balancers != "" || var.target_group_arns != "" ? "ELB" : "EC2"
  launch_configuration      = var.asg_type == "launch_configuration" ? aws_launch_configuration.lc[0].name : null
  load_balancers            = var.load_balancers != "" ? var.load_balancers : null
  max_size                  = var.asg_max_instances
  metrics_granularity       = "1Minute"
  min_elb_capacity          = var.instance_count
  min_size                  = var.instance_count
  name_prefix               = "${var.tags["Name"]}-${var.service}-"
  protect_from_scale_in     = var.scale_in_protection
  service_linked_role_arn   = var.asg_linked_role
  target_group_arns         = var.target_group_arns != "" ? var.target_group_arns : null
  termination_policies      = var.asg_terminate_policy
  vpc_zone_identifier       = var.subnets
  wait_for_capacity_timeout = var.asg_wait
  wait_for_elb_capacity     = var.instance_count
  tags = concat(data.null_data_source.asg-tags.*.outputs,
    [{ "key" = "Service", "value" = var.service, "propagate_at_launch" = true },
  { "key" = "ServiceComponent", "value" = var.service_component, "propagate_at_launch" = true }])
}

resource "aws_ecs_cluster" "jenkins" {
	  name = var.ecs_cluster_name
}

