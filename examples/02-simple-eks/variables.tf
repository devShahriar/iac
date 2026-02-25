# ===========================================
# Input Variables
# ===========================================

# -----------------------------------------
# AWS Configuration
# -----------------------------------------

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# -----------------------------------------
# Existing Infrastructure
# -----------------------------------------

variable "vpc_id" {
  description = "ID of your existing VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for EKS (minimum 2 subnets in different AZs)"
  type        = list(string)
}

# -----------------------------------------
# EKS Configuration
# -----------------------------------------

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "my-eks-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29"
}

# -----------------------------------------
# Node Group Configuration
# -----------------------------------------

variable "node_instance_types" {
  description = "EC2 instance types for worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}
