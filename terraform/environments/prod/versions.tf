terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "YOUR_STATE_BUCKET_NAME"   # Replace with your bucket name
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"                # Replace with your region
    encrypt        = true
    dynamodb_table = "YOUR_LOCK_TABLE_NAME"     # Replace with your table name
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project    = "devops-platform"
      ManagedBy  = "terraform"
      Repository = "terraform-aws-devops-platform"
    }
  }
}