module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.3"

  name = var.name
  cidr = var.vpc_cidr

  azs             = var.azs
  public_subnets  = [cidrsubnet(var.vpc_cidr, 8, 10), cidrsubnet(var.vpc_cidr, 8, 11)]
  private_subnets = [cidrsubnet(var.vpc_cidr, 8, 20), cidrsubnet(var.vpc_cidr, 8, 21)]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  # CRITICAL for ALB Controller auto-discovery:
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${var.name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.name}" = "shared"
  }

  tags = {
    Project = var.name
  }
}
