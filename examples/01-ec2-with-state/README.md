# Example: EC2 with State Management

> This example demonstrates how to set up an EC2 instance with Terraform, including state management and provider configuration.

---

## 📁 Files in This Example

| File | Purpose |
|------|---------|
| `versions.tf` | Terraform and provider version constraints |
| `providers.tf` | Provider configuration (AWS) |
| `variables.tf` | Input variable definitions |
| `main.tf` | Main resources (VPC, Subnet, EC2) |
| `outputs.tf` | Output values |
| `terraform.tfvars.example` | Example variable values |

---

## 🔧 State Management

### What is State?

Terraform state is a **JSON file** that maps your configuration to real-world resources.

```
Your Config (.tf)     State File (.tfstate)     Real Infrastructure
┌─────────────┐       ┌─────────────────┐       ┌─────────────────┐
│ aws_instance│  ──►  │ id: i-12345     │  ──►  │ EC2 Instance    │
│ "web"       │       │ ami: ami-xxx    │       │ in AWS          │
└─────────────┘       └─────────────────┘       └─────────────────┘
```

### Where Can State Be Stored?

| Backend | Description | Use Case |
|---------|-------------|----------|
| **Local** | File on your machine | Learning, personal projects |
| **S3** | AWS S3 bucket | Team collaboration with AWS |
| **Azure Blob** | Azure Storage | Team collaboration with Azure |
| **GCS** | Google Cloud Storage | Team collaboration with GCP |
| **Terraform Cloud** | HashiCorp's managed service | Enterprise teams |

### Local State (Default)

```hcl
# No backend configuration needed - state stored locally
# Creates: terraform.tfstate in current directory
```

### Remote State (S3)

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/ec2/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"  # For state locking
  }
}
```

---

## 🚀 How to Use This Example

### Prerequisites

1. AWS CLI installed and configured
2. Terraform installed (v1.0+)

### Steps

```bash
# 1. Navigate to this example
cd examples/01-ec2-with-state

# 2. Copy and edit variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# 3. Initialize Terraform
terraform init

# 4. Preview changes
terraform plan

# 5. Apply changes
terraform apply

# 6. View outputs
terraform output

# 7. Clean up (when done)
terraform destroy
```

---

## 📊 State Commands

```bash
# List all resources in state
terraform state list

# Show details of a specific resource
terraform state show aws_instance.web

# View the raw state file (JSON)
cat terraform.tfstate | jq

# Show state in human-readable format
terraform show
```

---

## 🔒 State Locking

When using remote backends like S3, use **DynamoDB for locking** to prevent concurrent modifications.

```
User A: terraform apply ──► Acquires Lock ──► Makes Changes ──► Releases Lock
                                    │
User B: terraform apply ──────────► ❌ BLOCKED (Lock held by User A)
```

---

## ⚠️ Important Notes

1. **Never commit state files** - They may contain secrets
2. **Use remote state** for team projects
3. **Enable encryption** for remote state
4. **Use state locking** to prevent conflicts
