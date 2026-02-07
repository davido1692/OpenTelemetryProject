variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EKS"
  type        = list(string)
}

variable "node_group_name" {
  description = "Managed node group name"
  type        = string
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.small"
}

variable "node_min_size" {
  description = "Min nodes"
  type        = number
  default     = 1
}

variable "node_desired_size" {
  description = "Desired nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Max nodes"
  type        = number
  default     = 4
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
variable "admin_principal_arn" {
  description = "IAM principal ARN to grant cluster admin access via EKS Access Entry"
  type        = string
}
