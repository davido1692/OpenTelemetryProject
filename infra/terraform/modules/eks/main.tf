module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  # version = "20.11.0"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids
  

  # Needed for IRSA (AWS Load Balancer Controller, OTel collector IAM later, etc.)

access_entries = {
  admin = {
    principal_arn = var.admin_principal_arn
    policy_associations = {
      admin = {
        # policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
        policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

        access_scope = {
          type = "cluster"
        }
      }
    }
  }
}





  enable_irsa = true


  # For a challenge, public endpoint keeps it simple (you can restrict later)
  cluster_endpoint_public_access = true

  # Managed node group (your scaling requirement)
  eks_managed_node_groups = {
    default = {
      name           = var.node_group_name
      instance_types = [var.node_instance_type]

      min_size     = var.node_min_size
      desired_size = var.node_desired_size
      max_size     = var.node_max_size

      iam_role_use_name_prefix = false
      iam_role_name            = "otel-dev-ng-role"  
      enable_cluster_creator_admin_permissions = true

      # Optional but helpful defaults
      ami_type      = "AL2_x86_64"
      capacity_type = "ON_DEMAND"
    }
  }

  tags = var.tags
}
