output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Cluster security group id"
  value       = module.eks.cluster_security_group_id
}

output "oidc_provider_arn" {
  description = "OIDC Provider ARN (for IRSA)"
  value       = module.eks.oidc_provider_arn
}
output "node_group_arns" {
  description = "Managed node group ARNs"
  value = try(
    module.eks.eks_managed_node_group_arns,
    [for ng in values(module.eks.eks_managed_node_groups) : ng.node_group_arn],
    [for ng in values(module.eks.eks_managed_node_groups) : ng.arn],
    []
  )
}

# output "node_group_arns" {
 # description = "Managed node group ARNs"
  # value       = module.eks.eks_managed_node_group_arns
#}
