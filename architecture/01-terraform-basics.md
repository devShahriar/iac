# Terraform Basic Concepts

> Understanding the fundamentals of Terraform

---

## What is Terraform?

Terraform is an **Infrastructure as Code (IaC)** tool that lets you define and manage infrastructure using declarative configuration files.

```mermaid
flowchart LR
    subgraph Traditional["❌ Traditional Way"]
        Manual["Manual clicks in<br/>AWS Console"]
    end
    
    subgraph IaC["✅ Infrastructure as Code"]
        Code["Write Code"] --> Apply["Run Terraform"] --> Infra["Infrastructure Created"]
    end
    
    style Traditional fill:#ffcdd2
    style IaC fill:#c8e6c9
```

---

## Key Concepts

### 1. Declarative vs Imperative

```mermaid
flowchart TB
    subgraph Declarative["✅ Declarative (Terraform)"]
        D1["You define WHAT you want"]
        D2["'I want 3 servers'"]
        D3["Terraform figures out HOW"]
    end
    
    subgraph Imperative["Imperative (Scripts)"]
        I1["You define HOW to do it"]
        I2["'Create server 1, then 2, then 3'"]
        I3["Step by step instructions"]
    end
    
    style Declarative fill:#e8f5e9
    style Imperative fill:#fff3e0
```

### 2. Idempotency

Running the same Terraform configuration multiple times produces the **same result**.

```mermaid
flowchart LR
    Config["Configuration:<br/>3 Servers"]
    
    Config -->|"Run 1"| Result1["3 Servers ✓"]
    Config -->|"Run 2"| Result2["3 Servers ✓"]
    Config -->|"Run 3"| Result3["3 Servers ✓"]
    
    style Config fill:#bbdefb
    style Result1 fill:#c8e6c9
    style Result2 fill:#c8e6c9
    style Result3 fill:#c8e6c9
```

---

## Core Building Blocks

```mermaid
mindmap
    root((Terraform<br/>Building Blocks))
        Providers
            AWS
            Azure
            GCP
            Kubernetes
        Resources
            aws_instance
            aws_vpc
            aws_s3_bucket
        Data Sources
            Query existing infra
            Read-only
        Variables
            Input parameters
            Reusability
        Outputs
            Export values
            Share between modules
        Modules
            Reusable packages
            Encapsulation
```

---

## HCL - HashiCorp Configuration Language

Terraform uses **HCL** (HashiCorp Configuration Language) for configuration files.

### Basic Syntax

```hcl
# This is a comment

# Block type with labels
resource "aws_instance" "web_server" {
  # Arguments
  ami           = "ami-12345678"
  instance_type = "t3.micro"
  
  # Nested block
  tags = {
    Name = "WebServer"
  }
}
```

### Block Structure

```mermaid
flowchart TB
    subgraph Block["HCL Block Structure"]
        Type["Block Type<br/>(resource, variable, output)"]
        Labels["Labels<br/>(resource type, name)"]
        Body["Body<br/>{arguments & nested blocks}"]
        
        Type --> Labels --> Body
    end
    
    subgraph Example["Example"]
        E1["resource"]
        E2["'aws_instance' 'web'"]
        E3["{ami = '...'<br/>instance_type = '...'}"]
        
        E1 --> E2 --> E3
    end
    
    style Block fill:#e3f2fd
    style Example fill:#fff3e0
```

---

## Terraform File Types

| Extension | Purpose |
|-----------|---------|
| `.tf` | Main configuration files (HCL) |
| `.tfvars` | Variable values |
| `.tfstate` | State file (JSON) |
| `.tfplan` | Saved execution plan |

### Recommended File Organization

```
project/
├── main.tf          # Main resources
├── variables.tf     # Input variable declarations
├── outputs.tf       # Output declarations
├── providers.tf     # Provider configuration
├── versions.tf      # Terraform & provider versions
├── terraform.tfvars # Variable values (don't commit secrets!)
└── README.md        # Documentation
```

---

## The Terraform Workflow

```mermaid
flowchart TD
    subgraph Write["1️⃣ WRITE"]
        W1["Create .tf files"]
        W2["Define resources"]
    end
    
    subgraph Init["2️⃣ INIT"]
        I1["terraform init"]
        I2["Download providers"]
        I3["Setup backend"]
    end
    
    subgraph Plan["3️⃣ PLAN"]
        P1["terraform plan"]
        P2["Preview changes"]
        P3["No changes made yet"]
    end
    
    subgraph Apply["4️⃣ APPLY"]
        A1["terraform apply"]
        A2["Create/Update resources"]
        A3["Update state"]
    end
    
    Write --> Init --> Plan --> Apply
    Apply -->|"Iterate"| Write
    
    style Write fill:#e8eaf6
    style Init fill:#e0f7fa
    style Plan fill:#fff3e0
    style Apply fill:#e8f5e9
```

---

## Variables

### Declaring Variables

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Number of instances"
  type        = number
  default     = 1
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}
```

### Using Variables

```hcl
resource "aws_instance" "web" {
  instance_type = var.instance_type
  count         = var.instance_count
  monitoring    = var.enable_monitoring
}
```

### Variable Precedence (Lowest to Highest)

```mermaid
flowchart TB
    D["1. Default value in variable block"]
    E["2. Environment variable (TF_VAR_name)"]
    F["3. terraform.tfvars file"]
    V["4. *.auto.tfvars files"]
    C["5. -var or -var-file on CLI"]
    
    D --> E --> F --> V --> C
    
    style C fill:#c8e6c9
    style D fill:#ffcdd2
```

---

## Outputs

Outputs expose values from your configuration.

```hcl
output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}
```

**Use cases:**
- Display information after `terraform apply`
- Pass data between modules
- Query with `terraform output`

---

## Next Steps

Continue to:
1. [Provider Architecture](./02-provider-architecture.md) - How providers work
2. [Terraform Architecture](./03-terraform-architecture.md) - Internal architecture
