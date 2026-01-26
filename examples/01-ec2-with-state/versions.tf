# ===========================================
# Terraform and Provider Version Constraints
# ===========================================
# This file pins the Terraform version and 
# specifies which providers are required.
# ===========================================

terraform {
  # Minimum Terraform version required
  required_version = ">= 1.0.0"

  # Required providers with version constraints
  required_providers {
    aws = {
      source  = "hashicorp/aws"  # Provider source address
      version = "~> 5.0"          # Allow 5.x versions
    }
  }

  # =========================================
  # Backend Configuration (State Storage)
  # =========================================
  
  # Option 1: Local Backend (Default)
  # State is stored in ./terraform.tfstate
  # Good for: Learning, personal projects
  
  # Option 2: S3 Backend (Uncomment to use)
  # State is stored in S3 with DynamoDB locking
  # Good for: Team collaboration, production
  
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "examples/ec2/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-locks"
  # }
}
