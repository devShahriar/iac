# Simple EC2 Instance Example

> Create an EC2 instance in your existing VPC using Terraform.

---

## What This Creates

| Resource | Description |
|----------|-------------|
| `aws_security_group` | Firewall rules (SSH + HTTP) |
| `aws_instance` | EC2 instance (Amazon Linux 2023) |

---

## Prerequisites

1. AWS CLI configured (`aws configure`)
2. Terraform installed
3. Existing VPC and Subnet in AWS

---

## Quick Start

```bash
# 1. Copy variables file
cp terraform.tfvars.example terraform.tfvars

# 2. Edit with your VPC and Subnet IDs
vim terraform.tfvars

# 3. Initialize
terraform init

# 4. Preview
terraform plan

# 5. Create
terraform apply

# 6. Destroy when done
terraform destroy
```

---

## Find Your VPC/Subnet IDs

```bash
# List VPCs
aws ec2 describe-vpcs \
  --query 'Vpcs[*].[VpcId,Tags[?Key==`Name`].Value|[0]]' \
  --output table

# List Subnets
aws ec2 describe-subnets \
  --query 'Subnets[*].[SubnetId,VpcId,AvailabilityZone]' \
  --output table
```

---

## Files

| File | Purpose |
|------|---------|
| `versions.tf` | Terraform/provider versions |
| `providers.tf` | AWS provider config |
| `variables.tf` | Input variables |
| `main.tf` | EC2 and Security Group |
| `outputs.tf` | Output values |
| `terraform.tfvars.example` | Example variable values |
