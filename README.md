# 🏗️ Infrastructure as Code (IaC) - Terraform Course

> Course repository containing Terraform architecture documentation and hands-on examples.

---

## 📁 Repository Structure

```
iac/
├── README.md                          # This file
├── architecture/                      # Terraform concepts with Mermaid diagrams
│   ├── README.md                      # Learning path
│   ├── 01-terraform-basics.md         # Basic concepts, HCL, workflow
│   ├── 02-provider-architecture.md    # How providers work
│   └── 03-terraform-architecture.md   # Internal architecture deep dive
│
└── examples/                          # Hands-on Terraform examples
    └── 01-ec2-with-state/             # EC2 setup with state management
        ├── README.md                  # Example documentation
        ├── versions.tf                # Terraform/provider versions
        ├── providers.tf               # Provider configuration
        ├── variables.tf               # Input variables
        ├── main.tf                    # Main resources
        ├── outputs.tf                 # Output values
        └── terraform.tfvars.example   # Example variable values
```

---

## 📚 Course Contents

### Day 1: Architecture & Internals

#### 📖 Theory (architecture/)

1. **[Terraform Basics](./architecture/01-terraform-basics.md)**
   - What is Terraform?
   - Declarative vs Imperative
   - HCL syntax
   - Variables & Outputs
   - Terraform workflow

2. **[Provider Architecture](./architecture/02-provider-architecture.md)**
   - What are Providers?
   - Plugin architecture (gRPC)
   - Provider configuration
   - Authentication methods
   - Provider aliases

3. **[Terraform Architecture](./architecture/03-terraform-architecture.md)**
   - Internal components
   - Dependency graphs (DAG)
   - Plan & Apply internals
   - Parallel execution

#### 💻 Hands-On (examples/)

1. **[EC2 with State Management](./examples/01-ec2-with-state/)**
   - Provider setup
   - State management (local & remote)
   - VPC, Subnet, Security Group
   - EC2 instance deployment
   - Outputs

---

## 🚀 Getting Started

### Prerequisites

```bash
# Install Terraform (macOS)
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Verify
terraform version

# Install AWS CLI
brew install awscli
aws configure
```

### View Mermaid Diagrams

Install VS Code extension: **Markdown Preview Mermaid Support**

Or view online at [mermaid.live](https://mermaid.live)

---

## 🎯 Quick Start

```bash
# 1. Clone and navigate
cd iac

# 2. Read the architecture docs
open architecture/01-terraform-basics.md

# 3. Try the example
cd examples/01-ec2-with-state
cp terraform.tfvars.example terraform.tfvars

# 4. Run Terraform
terraform init
terraform plan
terraform apply

# 5. Clean up
terraform destroy
```

---

## 📊 Terraform Workflow

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│  WRITE   │ →  │   INIT   │ →  │   PLAN   │ →  │  APPLY   │
│  (.tf)   │    │ providers│    │ preview  │    │ execute  │
└──────────┘    └──────────┘    └──────────┘    └──────────┘
```

---

## 🔗 Resources

- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [Terraform Registry](https://registry.terraform.io/)
- [AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

---

*Happy Terraforming! 🚀*
