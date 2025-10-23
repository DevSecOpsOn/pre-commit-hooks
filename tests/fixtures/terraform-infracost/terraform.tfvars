# Example terraform.tfvars for cost estimation

aws_region     = "us-east-1"
environment    = "dev"
instance_type  = "t3.small"
root_volume_size = 30
db_instance_class = "db.t3.small"
db_storage_size = 50
ebs_volume_size = 200
enable_nat_gateway = true
enable_load_balancer = true
