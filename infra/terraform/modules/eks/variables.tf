variable "name" { type = string }
variable "cluster_version" { type = string }
variable "vpc_id" { type = string }
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "node_instance_type" { type = string }
