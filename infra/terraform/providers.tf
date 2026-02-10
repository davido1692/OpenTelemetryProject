provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

# Kubernetes provider is configured after cluster is created; we’ll just output kubeconfig instructions.
