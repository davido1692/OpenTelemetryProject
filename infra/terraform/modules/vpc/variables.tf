variable "name" {
  description = "Name prefix for VPC resources"
  type        = string
}

variable "cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "az_count" {
  description = "How many AZs to use (2 recommended)"
  type        = number
  default     = 2
}

variable "enable_nat_gateway" {
  description = "Create NAT gateway(s) for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway (cheaper) instead of one per AZ"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Extra tags to apply to resources"
  type        = map(string)
  default     = {}
}
