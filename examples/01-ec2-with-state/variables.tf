# ===========================================
# Input Variables
# ===========================================
# Variables make your configuration reusable
# and allow customization without changing code.
# ===========================================

# -----------------------------------------
# General Configuration
# -----------------------------------------

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraform-demo"
}

# -----------------------------------------
# Network Configuration
# -----------------------------------------

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

# -----------------------------------------
# EC2 Configuration
# -----------------------------------------

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "web-server"
}

# -----------------------------------------
# Variable Types Examples
# -----------------------------------------

# String
variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "DevOps Team"
}

# Number
variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

# Boolean
variable "enable_public_ip" {
  description = "Assign public IP to instances"
  type        = bool
  default     = true
}

# List
variable "allowed_ssh_cidrs" {
  description = "List of CIDRs allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # In production, restrict this!
}

# Map
variable "extra_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
