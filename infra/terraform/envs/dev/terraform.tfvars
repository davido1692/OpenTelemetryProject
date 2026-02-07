region  = "us-east-1"
project = "opentelemetryproject"
env     = "dev"

vpc_cidr        = "10.0.0.0/16"
cluster_version = "1.29"

node_instance_type = "t3.small"
node_min_size      = 1
node_desired_size  = 1
node_max_size      = 4

ecr_repo_name       = "flask-hello"
admin_principal_arn = "arn:aws:iam::751545121618:user/Admin"
