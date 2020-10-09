# Mandatory:

variable "desired_service_count" {
  type = string
  default = 1
}

variable "ecs_cluster_name" {
  type    = string
  default = "luminor_assignment"
}

variable "instance_type" {
  type = string
}

variable "security_groups" {
  type = list(string)
}

variable "service" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}

# Can be overriden:

variable "ami_id" {
  type    = string
  default = ""
}

variable "asg_cooldown" {
  type    = string
  default = "300"
}

variable "asg_grace_period" {
  type    = string
  default = "300"
}

variable "asg_linked_role" {
  type    = string
  default = ""
}

variable "asg_max_instances" {
  type    = string
  default = "1"
}

variable "asg_metrics" {
  type    = list(string)
  default = ["GroupInServiceInstances"]
}

variable "asg_terminate_policy" {
  type    = list(string)
  default = ["Default"]
}

variable "asg_type" {
  type    = string
  default = "launch_template"
}

variable "asg_wait" {
  type    = string
  default = "10m"
}

variable "availability_zone" {
  type    = string
  default = "eu-west-1a"
}

variable "aws_account_id" {
  type    = string
  default = ""
}

variable "aws_region" {
  type    = string
  default = ""
}

variable "block_devices" {
  type = list(map(string))
  default = [{
    root_device           = true
    device_name           = "/dev/sda1"
    delete_on_termination = true
    iops                  = 0
    volume_size           = 30
    volume_type           = "gp2"
  }]
}

variable "capacity_preference" {
  type    = string
  default = "none"
}

variable "client" {
  type    = string
  default = "Managed"
}

variable "dependencies" {
  type    = list(string)
  default = []
}

variable "drive_letters" {
  type    = list(string)
  default = ["f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
}

variable "gpu_specifications" {
  type    = string
  default = ""
}

variable "iam_profile" {
  type    = string
  default = ""
}

variable "instance_count" {
  type    = string
  default = "1"
}

variable "instance_initiated_shutdown_behavior" {
  type    = string
  default = "stop"
}

variable "license_specification_arn" {
  type    = string
  default = ""
}

variable "load_balancers" {
  type    = list(string)
  default = [""]
}

variable "service_component" {
  type    = string
  default = "ApplicationServer"
}

variable "scale_in_protection" {
  type    = string
  default = false
}

variable "target_group_arns" {
  type    = list(string)
  default = [""]
}

variable "unoptimized_ebs_ec2s" {
  type    = list(string)
  default = ["c1.medium", "c3.8xlarge", "c3.large", "cc2.8xlarge", "cr1.8xlarge", "g2.8xlarge", "hs1.8xlarge", "i2.8xlarge", "m1.medium", "m1.small", "m2.2large", "m2.xlarge", "m3.large", "m3.medium", "r3.2xlarge", "r3.8xlarge", "r3.large", "t1.micro", "t2.2xlarge", "t2.large", "t2.medium", "t2.micro", "t2.nano", "t2.small", "t2.xlarge"]
}

variable "user_data_additional_vars" {
  type    = map(string)
  default = {}
}

