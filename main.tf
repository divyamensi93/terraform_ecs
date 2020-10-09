####################################
########## INITIALIZATION ##########
####################################

terraform {
  required_version = ">= 0.12.10"
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

########## SERVICES ##########

locals {
  services = split(",", replace(var.services, " ", ""))
}

########## TAGGING STRATEGY ##########

locals {
  overall = {
    "CreatedBy"   = "Terraform 0.12.10"
    "Environment" = var.environment
    "Name"        = "Luminor-${var.environment}"
  }

  private_network = {
    "NetworkTier" = "Private"
  }

  public_network = {
    "NetworkTier" = "Public"
  }

  instances = {
    "Owner" = "Divya"
    "Name"  = "Luminor-assignment"
  }
}

########## IAM ROLES ##########

module "iam_vpc_flow_log" {
  source = "./resources/iam_role"
  policies   = ["Flow-Log"]
  principals = "vpc-flow-logs.amazonaws.com"
  service    = "VPC"
  tags       = local.overall
}

###################################
########## NETWORK LAYER ##########
###################################

module "vpc" {
  source = "./resources/vpc"

  cidr_block       = var.platform_cidr
  iam_log_role_arn = module.iam_vpc_flow_log.arn
  log_group_arn    = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:${var.vpc_log_group}"
  tags             = local.overall
}

module "public_subnets" {
  source = "./resources/subnet"

  vpc_cidr_block          = module.vpc.cidr_block
  vpc_cidr_increment      = "4"
  map_public_ip_on_launch = true
  vpc_id                  = module.vpc.id
  tags                    = merge(local.overall, local.public_network)
}

########## GATEWAYS ##########

module "internet_gateway" {
  source = "./resources/internet_gateway"

  vpc_id = module.vpc.id
  tags   = merge(local.overall, local.public_network)
}

########## ROUTES / PEERINGS ##########

module "internet_gateway_route" {
  source = "./resources/route"

  route_tables           = module.public_subnets.route_tables
  destination_cidr_block = "0.0.0.0/0"
  gateway_ids            = module.internet_gateway.id
}


module "ebs_kms_key" {
  source = "./resources/kms_key"

  aws_account_id = data.aws_caller_identity.current.account_id
  aws_service    = "EBS"
  region         = var.aws_region
  principals     = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"]
  tags           = local.overall
}

########## EBS VOLUMES ##########

module "encrypted_ebs_volume" {
  source = "./resources/ebs_volume"

  aws_account_id = data.aws_caller_identity.current.account_id
  kms_key_id     = module.ebs_kms_key.cmk_arn
  region         = var.aws_region
  size           = "1"
  tags           = local.overall
}

##############################
########## SERVICES ##########
##############################

module "container_registry" {
  source = "./resources/ecr_repository"

  services = local.services
  tags     = local.overall
}

########## JENKINS ##########

module "JENKINS_ec2_sg" {
  source = "./resources/security_group"

  rules = [{ protocol = "TCP", from_port = "22", to_port = "22", cidr_blocks = [module.vpc.cidr_block] },
    { protocol = "TCP", from_port = "80", to_port = "80", cidr_blocks = ["0.0.0.0/0"] },
    { protocol = "TCP", from_port = "8080", to_port = "8080", cidr_blocks = ["0.0.0.0/0"] },
  { protocol = "TCP", from_port = "50000", to_port = "50000", cidr_blocks = ["0.0.0.0/0"] }]
  service = "JENKINS"
  vpc_id  = module.vpc.id
  tags    = merge(local.overall, local.public_network)
}

module "JENKINS-iam-role" {
  source = "./resources/iam_role"

  aws_account_id = data.aws_caller_identity.current.account_id
  policies       = ["ECS-Instance", "ECR-Pull", "ECS-Service", "EBS-Attach"]
  region         = var.aws_region
  service        = "JENKINS"
  tags           = local.overall
}

module "JENKINS" {
  source       = "./resources/ec2"
  dependencies = [module.internet_gateway_route.ids[0]]

  ami_id         = var.ami_id
  asg_type       = "launch_configuration"
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = var.aws_region
  block_devices = [{ delete_on_termination = true, volume_size = 30, volume_type = "gp2", root_device = true },
  { delete_on_termination = true, volume_size = 20, volume_type = "gp2" }]
  iam_profile     = module.JENKINS-iam-role.instance_profile
  instance_type   = "t2.medium"
  security_groups = [module.JENKINS_ec2_sg.id]
  service         = "JENKINS"
  subnets         = module.public_subnets.ids
  tags            = merge(local.overall, local.public_network, local.instances)
}
