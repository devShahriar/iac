# Simple EKS Cluster Example

> Create an EKS cluster with managed node group in your existing VPC.

---

## What This Creates

| Resource                              | Description                           |
| ------------------------------------- | ------------------------------------- |
| `aws_iam_role` (x2)                   | IAM roles for cluster and nodes       |
| `aws_iam_role_policy_attachment` (x4) | Required IAM policies                 |
| `aws_security_group`                  | Security group for EKS cluster        |
| `aws_eks_cluster`                     | The EKS cluster                       |
| `aws_eks_node_group`                  | Managed node group with EC2 instances |

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                      Your VPC                           │
│  ┌─────────────────┐       ┌─────────────────┐         │
│  │   Subnet AZ-1   │       │   Subnet AZ-2   │         │
│  │  ┌───────────┐  │       │  ┌───────────┐  │         │
│  │  │  Node 1   │  │       │  │  Node 2   │  │         │
│  │  └───────────┘  │       │  └───────────┘  │         │
│  └────────┬────────┘       └────────┬────────┘         │
│           │                         │                   │
│           └───────────┬─────────────┘                   │
│                       │                                 │
│              ┌────────┴────────┐                       │
│              │   EKS Cluster   │                       │
│              │  (Control Plane)│                       │
│              └─────────────────┘                       │
└─────────────────────────────────────────────────────────┘
```

---

## Prerequisites

1. AWS CLI configured
2. Terraform installed
3. Existing VPC with **at least 2 subnets in different AZs**
4. kubectl installed (for cluster access)

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

# 5. Create (takes ~10-15 minutes)
terraform apply

# 6. Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster

# 7. Test connection
kubectl get nodes

# 8. Destroy when done
terraform destroy
```

---

## Find Your VPC/Subnet IDs

```bash
# List VPCs
aws ec2 describe-vpcs \
  --query 'Vpcs[*].[VpcId,Tags[?Key==`Name`].Value|[0]]' \
  --output table

# List Subnets (need at least 2 in different AZs)
aws ec2 describe-subnets \
  --query 'Subnets[*].[SubnetId,VpcId,AvailabilityZone]' \
  --output table
```

---

## Estimated Costs

| Resource             | Cost (approx)            |
| -------------------- | ------------------------ |
| EKS Cluster          | ~$0.10/hour (~$73/month) |
| t3.medium nodes (x2) | ~$0.04/hour each         |

> **Note**: Destroy resources when not in use to avoid charges!

---

## Files

| File                       | Purpose                           |
| -------------------------- | --------------------------------- |
| `versions.tf`              | Terraform/provider versions       |
| `providers.tf`             | AWS provider config               |
| `variables.tf`             | Input variables                   |
| `main.tf`                  | IAM, EKS cluster, Node group      |
| `outputs.tf`               | Cluster endpoint, kubectl command |
| `terraform.tfvars.example` | Example values                    |
