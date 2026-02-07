provider "aws" {
  region = var.region
}

locals {
  name         = "${var.project}-${var.env}"
  vpc_name     = "${local.name}-vpc"
  cluster_name = "${local.name}-eks"
  nodegroup    = "${local.name}-ng"

  tags = {
    Project = var.project
    Env     = var.env
  }
}

module "vpc" {
  source = "../../modules/vpc"

  name = local.vpc_name
  cidr = var.vpc_cidr

  az_count           = 2
  enable_nat_gateway = true
  single_nat_gateway = true

  tags = local.tags
}

module "eks" {
  source = "../../modules/eks"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  admin_principal_arn = var.admin_principal_arn


  node_group_name    = local.nodegroup
  node_instance_type = var.node_instance_type
  node_min_size      = var.node_min_size
  node_desired_size  = var.node_desired_size
  node_max_size      = var.node_max_size

  tags = local.tags
}

module "ecr" {
  source = "../../modules/ecr"

  name = var.ecr_repo_name
  tags = local.tags
}
