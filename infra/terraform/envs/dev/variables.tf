variable "region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  type    = string
  default = "opentelemetryproject"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "cluster_version" {
  type    = string
  default = "1.29"
}

variable "node_instance_type" {
  type    = string
  default = "t3.small"
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_desired_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 4
}

variable "ecr_repo_name" {
  type    = string
  default = "flask-hello"
}
variable "admin_principal_arn" {
  description = "IAM user/role ARN to grant EKS admin access"
  type        = string
}
