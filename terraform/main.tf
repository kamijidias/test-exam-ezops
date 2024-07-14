provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

# #Criar o bucket S3
# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "test-andrew-terraform-state"
#   acl    = "private"

#   versioning {
#     enabled = true
#   }

#   tags = {
#     Name        = "Terraform State Bucket"
#     Environment = var.environment
#   }
# }


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "test-andrew-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "test-andrew-terraform-locks"
    encrypt        = true
  }
}

# # Criar a tabela DynamoDB
# resource "aws_dynamodb_table" "terraform_locks" {
#   name         = "test-andrew-terraform-locks"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }

#   tags = {
#     Name        = "Terraform Locks Table"
#     Environment = var.environment
#   }
# }