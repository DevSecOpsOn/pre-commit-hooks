provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "example" {
  bucket = "my-test-bucket-12345"
  
  # Missing encryption configuration
  # Missing versioning
}

resource "aws_security_group" "example" {
  name        = "test-sg"
  description = "Test security group"
  
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Too open
  }
}
