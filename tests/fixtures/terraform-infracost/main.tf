# Terraform configuration for Infracost testing
# This creates AWS resources with clear cost implications

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# EC2 Instance - costs vary by instance type
resource "aws_instance" "web_server" {
  ami           = var.ami_id
  instance_type = var.instance_type  # t3.micro, t3.small, t3.medium, etc.

  root_block_device {
    volume_size = var.root_volume_size  # GB
    volume_type = "gp3"
  }

  tags = {
    Name        = "web-server"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# RDS Database - significant cost component
resource "aws_db_instance" "database" {
  identifier           = "myapp-db"
  engine              = "postgres"
  engine_version      = "15.3"
  instance_class      = var.db_instance_class  # db.t3.micro, db.t3.small, etc.
  allocated_storage   = var.db_storage_size    # GB
  storage_type        = "gp3"
  
  db_name  = "myappdb"
  username = "admin"
  password = "changeme123"  # In production, use secrets manager
  
  skip_final_snapshot = true
  
  tags = {
    Name        = "myapp-database"
    Environment = var.environment
  }
}

# S3 Bucket - storage costs
resource "aws_s3_bucket" "data_bucket" {
  bucket = "myapp-data-${var.environment}"

  tags = {
    Name        = "Data Bucket"
    Environment = var.environment
  }
}

# S3 Bucket versioning
resource "aws_s3_bucket_versioning" "data_bucket" {
  bucket = aws_s3_bucket.data_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# EBS Volume - additional storage costs
resource "aws_ebs_volume" "data_volume" {
  availability_zone = "${var.aws_region}a"
  size              = var.ebs_volume_size  # GB
  type              = "gp3"
  iops              = 3000
  throughput        = 125

  tags = {
    Name        = "data-volume"
    Environment = var.environment
  }
}

# NAT Gateway - significant cost (per hour + data transfer)
resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? 1 : 0
  
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name        = "main-nat-gateway"
    Environment = var.environment
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"

  tags = {
    Name        = "nat-eip"
    Environment = var.environment
  }
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "main-vpc"
    Environment = var.environment
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  count             = 1
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name        = "public-subnet"
    Environment = var.environment
  }
}

# Application Load Balancer - costs per hour + data processed
resource "aws_lb" "main" {
  count              = var.enable_load_balancer ? 1 : 0
  name               = "main-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id

  tags = {
    Name        = "main-alb"
    Environment = var.environment
  }
}
