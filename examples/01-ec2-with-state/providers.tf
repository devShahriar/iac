# ===========================================
# Provider Configuration
# ===========================================
# Providers are plugins that Terraform uses
# to interact with cloud platforms and APIs.
# ===========================================

# AWS Provider Configuration
provider "aws" {
  # Region where resources will be created
  region = var.aws_region

  # =========================================
  # Authentication Options (pick one):
  # =========================================
  
  # Option 1: Environment Variables (Recommended)
  # Export before running terraform:
  #   export AWS_ACCESS_KEY_ID="your-access-key"
  #   export AWS_SECRET_ACCESS_KEY="your-secret-key"
  
  # Option 2: AWS CLI Profile
  # profile = "your-profile-name"
  
  # Option 3: IAM Instance Profile (for EC2/ECS)
  # No configuration needed - uses instance metadata
  
  # Option 4: Explicit credentials (NOT recommended)
  # access_key = "AKIA..."
  # secret_key = "..."

  # =========================================
  # Default Tags
  # =========================================
  # These tags are automatically applied to
  # all resources created by this provider.
  
  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = "IaC-Course"
    }
  }
}

# =========================================
# Multiple Provider Example (Aliases)
# =========================================
# Uncomment to deploy resources in multiple regions

# provider "aws" {
#   alias  = "us_west"
#   region = "us-west-2"
#   
#   default_tags {
#     tags = {
#       Environment = var.environment
#       ManagedBy   = "Terraform"
#       Region      = "us-west-2"
#     }
#   }
# }

# Usage with alias:
# resource "aws_instance" "west_server" {
#   provider = aws.us_west
#   ...
# }
