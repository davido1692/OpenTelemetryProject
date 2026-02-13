module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.11.0"

  cluster_name    = var.name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = false

  eks_managed_node_groups = {
    default = {
      instance_types = [var.node_instance_type]

      min_size     = 2
      max_size     = 4
      desired_size = 2

      capacity_type = "ON_DEMAND"
    }
  }

  tags = {
    Project = var.name
  }
}
