data "aws_availability_zones" "available" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  # Predictable subnet plan inside a /16 (adjust if you change VPC CIDR)
  # Public:  10.0.101.0/24, 10.0.102.0/24
  # Private: 10.0.1.0/24,   10.0.2.0/24
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  # Limit lists to az_count so this module still works if az_count=1
  public_subnets_sliced  = slice(local.public_subnets, 0, var.az_count)
  private_subnets_sliced = slice(local.private_subnets, 0, var.az_count)

  base_tags = merge(
    var.tags,
    { Name = var.name }
  )
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.1"

  name = var.name
  cidr = var.cidr

  azs             = local.azs
  public_subnets  = local.public_subnets_sliced
  private_subnets = local.private_subnets_sliced

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  enable_dns_hostnames = true
  enable_dns_support   = true

  # These tags help the AWS Load Balancer Controller choose subnets
  public_subnet_tags = merge(local.base_tags, {
    "kubernetes.io/role/elb" = "1"
  })

  private_subnet_tags = merge(local.base_tags, {
    "kubernetes.io/role/internal-elb" = "1"
  })

  tags = local.base_tags
}
