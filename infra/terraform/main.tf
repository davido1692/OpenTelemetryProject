locals {
  name = var.project
  azs  = slice(data.aws_availability_zones.available.names, 0, 2)
}

module "vpc" {
  source   = "./modules/vpc"
  name     = local.name
  vpc_cidr = var.vpc_cidr
  azs      = local.azs
}

module "eks" {
  source            = "./modules/eks"
  name              = local.name
  cluster_version   = var.cluster_version
  vpc_id            = module.vpc.vpc_id
  private_subnets   = module.vpc.private_subnets
  public_subnets    = module.vpc.public_subnets
  node_instance_type = var.node_instance_type
}
