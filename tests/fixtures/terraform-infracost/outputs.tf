# Outputs for reference

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web_server.id
}

output "database_endpoint" {
  description = "RDS database endpoint"
  value       = aws_db_instance.database.endpoint
  sensitive   = true
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.data_bucket.id
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}
