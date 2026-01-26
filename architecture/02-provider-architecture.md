# Terraform Provider Architecture

> Understanding how Providers work in Terraform

---

## What is a Provider?

A **Provider** is a plugin that enables Terraform to interact with cloud platforms, SaaS providers, and other APIs.

```mermaid
flowchart LR
    TF["Terraform Core"]
    
    subgraph Providers["Providers (Plugins)"]
        AWS["AWS Provider"]
        Azure["Azure Provider"]
        GCP["GCP Provider"]
        K8s["Kubernetes Provider"]
    end
    
    subgraph APIs["Cloud APIs"]
        AWSAPI["AWS API"]
        AzureAPI["Azure API"]
        GCPAPI["GCP API"]
        K8sAPI["K8s API"]
    end
    
    TF <--> AWS <--> AWSAPI
    TF <--> Azure <--> AzureAPI
    TF <--> GCP <--> GCPAPI
    TF <--> K8s <--> K8sAPI
    
    style TF fill:#fff3e0
    style Providers fill:#e3f2fd
    style APIs fill:#e8f5e9
```

---

## Provider Responsibilities

```mermaid
mindmap
    root((Provider<br/>Responsibilities))
        Authentication
            API Keys
            Access Tokens
            IAM Roles
        Resource Management
            CREATE resources
            READ current state
            UPDATE resources
            DELETE resources
        Schema Definition
            Define resource types
            Define data sources
            Attribute types
        API Translation
            Convert HCL to API calls
            Handle API responses
            Error handling
```

---

## How Providers Work

### Plugin Architecture

Providers run as **separate processes** and communicate with Terraform Core via **gRPC**.

```mermaid
flowchart TB
    subgraph TFProcess["Terraform Core Process"]
        Core["Terraform Core"]
        RPC["gRPC Client"]
    end
    
    subgraph ProviderProcess["Provider Process (Separate)"]
        Server["gRPC Server"]
        Logic["Provider Logic"]
        SDK["Terraform Plugin SDK"]
    end
    
    subgraph Cloud["Cloud Provider"]
        API["REST API"]
    end
    
    Core <--> RPC
    RPC <-->|"gRPC Protocol"| Server
    Server <--> Logic
    Logic <--> SDK
    SDK <-->|"HTTPS"| API
    
    style TFProcess fill:#e3f2fd
    style ProviderProcess fill:#fff3e0
    style Cloud fill:#e8f5e9
```

### Provider Lifecycle

```mermaid
sequenceDiagram
    participant TF as Terraform Core
    participant Provider as Provider Plugin
    participant API as Cloud API
    
    Note over TF,Provider: 1. Initialization
    TF->>TF: terraform init
    TF->>TF: Download provider binary
    TF->>Provider: Start provider process
    Provider-->>TF: Handshake complete
    
    Note over TF,Provider: 2. Configuration
    TF->>Provider: Configure(credentials, region)
    Provider->>API: Authenticate
    API-->>Provider: Auth successful
    Provider-->>TF: Provider ready
    
    Note over TF,API: 3. Operations
    TF->>Provider: ReadResource(aws_instance.web)
    Provider->>API: DescribeInstances
    API-->>Provider: Instance details
    Provider-->>TF: Current state
    
    TF->>Provider: CreateResource(aws_instance.new)
    Provider->>API: RunInstances
    API-->>Provider: Instance created
    Provider-->>TF: New resource state
    
    Note over TF,Provider: 4. Shutdown
    TF->>Provider: Shutdown
    Provider-->>TF: Goodbye
```

---

## Configuring Providers

### Basic Configuration

```hcl
# providers.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

### Provider with Authentication

```hcl
# Option 1: Explicit credentials (NOT recommended for production)
provider "aws" {
  region     = "us-east-1"
  access_key = "AKIA..."
  secret_key = "..."
}

# Option 2: Environment variables (Recommended)
# Export these before running terraform:
# export AWS_ACCESS_KEY_ID="AKIA..."
# export AWS_SECRET_ACCESS_KEY="..."
provider "aws" {
  region = "us-east-1"
}

# Option 3: AWS Profile
provider "aws" {
  region  = "us-east-1"
  profile = "my-profile"
}

# Option 4: IAM Role (Best for EC2/ECS)
provider "aws" {
  region = "us-east-1"
  # Uses instance profile automatically
}
```

### Multiple Provider Configurations (Aliases)

```hcl
# Default provider (us-east-1)
provider "aws" {
  region = "us-east-1"
}

# Aliased provider (eu-west-1)
provider "aws" {
  alias  = "europe"
  region = "eu-west-1"
}

# Using the default provider
resource "aws_instance" "us_server" {
  ami           = "ami-12345"
  instance_type = "t3.micro"
}

# Using the aliased provider
resource "aws_instance" "eu_server" {
  provider      = aws.europe
  ami           = "ami-67890"
  instance_type = "t3.micro"
}
```

```mermaid
flowchart TB
    subgraph Config["Provider Aliases"]
        Default["provider 'aws'<br/>region = us-east-1"]
        Europe["provider 'aws'<br/>alias = 'europe'<br/>region = eu-west-1"]
    end
    
    subgraph Resources["Resources"]
        US["aws_instance.us_server<br/>(uses default)"]
        EU["aws_instance.eu_server<br/>(provider = aws.europe)"]
    end
    
    Default --> US
    Europe --> EU
    
    style Default fill:#bbdefb
    style Europe fill:#c8e6c9
```

---

## Provider Version Constraints

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"      # >= 5.0.0 and < 6.0.0
    }
    
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0, < 4.0"
    }
    
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"       # Exact version
    }
  }
}
```

### Version Constraint Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| `=` or none | Exact version | `= 5.0.0` |
| `!=` | Not equal | `!= 5.0.0` |
| `>`, `>=`, `<`, `<=` | Comparison | `>= 5.0.0` |
| `~>` | Pessimistic (allow rightmost increment) | `~> 5.0` allows `5.x` |

---

## Provider Registry

Providers are distributed through the **Terraform Registry**.

```mermaid
flowchart TD
    subgraph Registry["Terraform Registry"]
        Official["Official Providers<br/>(hashicorp/*)"]
        Partner["Partner Providers<br/>(verified vendors)"]
        Community["Community Providers<br/>(anyone)"]
    end
    
    subgraph Examples["Examples"]
        AWS["hashicorp/aws"]
        Datadog["datadog/datadog"]
        Custom["mycorp/internal"]
    end
    
    Official --> AWS
    Partner --> Datadog
    Community --> Custom
    
    style Official fill:#c8e6c9
    style Partner fill:#fff9c4
    style Community fill:#e3f2fd
```

### Provider Source Address Format

```
[hostname/]namespace/name

Examples:
- hashicorp/aws              → registry.terraform.io/hashicorp/aws
- datadog/datadog            → registry.terraform.io/datadog/datadog
- mycorp.com/internal/myapp  → mycorp.com/internal/myapp
```

---

## What Happens During `terraform init`

```mermaid
flowchart TD
    Init["terraform init"]
    
    Init --> ReadConfig["Read required_providers"]
    ReadConfig --> CheckLock{"Lock file exists?"}
    
    CheckLock -->|"Yes"| UseLock["Use locked versions"]
    CheckLock -->|"No"| Resolve["Resolve versions from constraints"]
    
    UseLock --> Download
    Resolve --> Download["Download providers"]
    
    Download --> Verify["Verify checksums"]
    Verify --> Install["Install to .terraform/providers/"]
    Install --> WriteLock["Update .terraform.lock.hcl"]
    WriteLock --> Done["Ready!"]
    
    style Init fill:#90caf9
    style Done fill:#a5d6a7
```

### Directory Structure After Init

```
project/
├── .terraform/
│   └── providers/
│       └── registry.terraform.io/
│           └── hashicorp/
│               └── aws/
│                   └── 5.31.0/
│                       └── darwin_arm64/
│                           └── terraform-provider-aws_v5.31.0
└── .terraform.lock.hcl    # Dependency lock file
```

---

## Provider CRUD Operations

Providers implement **CRUD** (Create, Read, Update, Delete) operations for each resource type.

```mermaid
flowchart LR
    subgraph Operations["Provider Operations"]
        Create["CREATE<br/>➕ New resource"]
        Read["READ<br/>📖 Get current state"]
        Update["UPDATE<br/>🔄 Modify in-place"]
        Delete["DELETE<br/>🗑️ Remove resource"]
    end
    
    subgraph API["Translated to API Calls"]
        C_API["POST /instances"]
        R_API["GET /instances/{id}"]
        U_API["PUT /instances/{id}"]
        D_API["DELETE /instances/{id}"]
    end
    
    Create --> C_API
    Read --> R_API
    Update --> U_API
    Delete --> D_API
    
    style Create fill:#c8e6c9
    style Read fill:#bbdefb
    style Update fill:#fff9c4
    style Delete fill:#ffcdd2
```

---

## Popular Providers

| Provider | Source | Use Case |
|----------|--------|----------|
| AWS | `hashicorp/aws` | Amazon Web Services |
| Azure | `hashicorp/azurerm` | Microsoft Azure |
| Google | `hashicorp/google` | Google Cloud Platform |
| Kubernetes | `hashicorp/kubernetes` | K8s cluster management |
| Helm | `hashicorp/helm` | Helm chart deployment |
| Docker | `kreuzwerker/docker` | Docker containers |
| GitHub | `integrations/github` | GitHub resources |
| Datadog | `datadog/datadog` | Monitoring |

---

## Next Steps

Continue to:
1. [Terraform Architecture](./03-terraform-architecture.md) - Complete internal architecture
