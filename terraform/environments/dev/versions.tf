terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # -----------------------------------------------------------------------------
  # Remote State — S3 Backend
  #
  # Terraform state is stored remotely in S3 so that:
  #   1. Multiple team members can share state safely
  #   2. State is not committed to Git (which would expose infrastructure secrets)
  #   3. State locking (via DynamoDB) prevents simultaneous applies
  #
  # IMPORTANT: Before running terraform init, the S3 bucket and DynamoDB table
  # must already exist. Run scripts/terraform/bootstrap-state.sh first.
  #
  # The bucket name and DynamoDB table name below MUST match what
  # bootstrap-state.sh created.
  # -----------------------------------------------------------------------------
  backend "s3" {
    bucket         = "YOUR_STATE_BUCKET_NAME"   # Replace with your bucket name
    key            = "dev/terraform.tfstate"
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
