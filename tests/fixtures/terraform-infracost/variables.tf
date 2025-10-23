# Variables for Infracost testing

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"  # ~$7.50/month
  # Options: t3.micro, t3.small (~$15/month), t3.medium (~$30/month)
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20  # ~$2/month
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"  # ~$15/month
  # Options: db.t3.micro, db.t3.small (~$30/month), db.t3.medium (~$60/month)
}

variable "db_storage_size" {
  description = "RDS storage size in GB"
  type        = number
  default     = 20  # ~$2.30/month
}

variable "ebs_volume_size" {
  description = "EBS volume size in GB"
  type        = number
  default     = 100  # ~$10/month
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway (adds ~$32/month)"
  type        = bool
  default     = false
}

variable "enable_load_balancer" {
  description = "Enable Application Load Balancer (adds ~$16/month)"
  type        = bool
  default     = false
}
