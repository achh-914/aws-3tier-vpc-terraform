# 1. S3 Bucket for Terraform Remote State
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "achh-914-tf-state-bucket"
  force_destroy = true

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name        = "achh-914-tf-state-bucket"
    Environment = "Production"
  }
}

# Versioning to keep state history
resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block Public Access
resource "aws_s3_bucket_public_access_block" "state_public_access" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 2. DynamoDB Table for State Locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "aws-3tier-tf-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "aws-3tier-tf-locks"
    Environment = "Production"
  }
}

terraform {
  backend "s3" {
    bucket         = "achh-914-tf-state-bucket"
    key            = "prod/3tier-vpc/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "aws-3tier-tf-locks"
    encrypt        = true
  }
}
