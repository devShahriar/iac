# Terraform Internal Architecture

> Deep dive into how Terraform works under the hood

---

## High-Level Architecture

```mermaid
flowchart TB
    subgraph User["👤 User Layer"]
        HCL["📄 HCL Configuration Files<br/>(.tf files)"]
        CLI["⌨️ Terraform CLI"]
    end
    
    subgraph Core["🔧 Terraform Core"]
        Parser["Parser & Validator"]
        Graph["Graph Builder"]
        Planner["Plan Generator"]
        Executor["Execution Engine"]
    end
    
    subgraph State["💾 State Layer"]
        StateFile["terraform.tfstate"]
        Backend["Backend<br/>(Local/Remote)"]
    end
    
    subgraph Providers["🔌 Provider Layer"]
        AWS["AWS Provider"]
        Azure["Azure Provider"]
        GCP["GCP Provider"]
        More["...3000+ more"]
    end
    
    subgraph Infra["☁️ Infrastructure"]
        Cloud["Cloud Resources"]
    end
    
    HCL --> CLI
    CLI --> Parser
    Parser --> Graph
    Graph --> Planner
    Planner --> Executor
    
    Executor <--> StateFile
    StateFile <--> Backend
    
    Executor <--> AWS
    Executor <--> Azure
    Executor <--> GCP
    Executor <--> More
    
    AWS --> Cloud
    Azure --> Cloud
    GCP --> Cloud
    
    style User fill:#e1f5fe
    style Core fill:#fff3e0
    style State fill:#f3e5f5
    style Providers fill:#e8f5e9
    style Infra fill:#fce4ec
```

---

## Terraform Core Components

```mermaid
flowchart TB
    subgraph Core["Terraform Core"]
        direction TB
        
        subgraph ConfigLoader["Configuration Loader"]
            Lexer["Lexer/Tokenizer"]
            Parser["HCL Parser"]
            Validator["Validator"]
        end
        
        subgraph GraphEngine["Graph Engine"]
            Builder["Graph Builder"]
            Walker["Graph Walker"]
            Transformer["Graph Transformer"]
        end
        
        subgraph PlanEngine["Plan Engine"]
            Differ["Diff Calculator"]
            PlanBuilder["Plan Builder"]
        end
        
        subgraph ApplyEngine["Apply Engine"]
            Executor["Resource Executor"]
            StateManager["State Manager"]
        end
    end
    
    ConfigLoader --> GraphEngine
    GraphEngine --> PlanEngine
    PlanEngine --> ApplyEngine
    
    style ConfigLoader fill:#e3f2fd
    style GraphEngine fill:#fff3e0
    style PlanEngine fill:#e8f5e9
    style ApplyEngine fill:#f3e5f5
```

---

## Configuration Processing

### How Terraform Reads Your Code

```mermaid
flowchart LR
    subgraph Input["Input"]
        TF["main.tf"]
        Vars["variables.tf"]
        Out["outputs.tf"]
    end
    
    subgraph Processing["Processing"]
        Lex["1. Lexer<br/>Tokenize"]
        Parse["2. Parser<br/>Build AST"]
        Validate["3. Validator<br/>Check syntax"]
        Eval["4. Evaluator<br/>Resolve expressions"]
    end
    
    subgraph Output["Output"]
        Config["Complete<br/>Configuration"]
    end
    
    Input --> Lex --> Parse --> Validate --> Eval --> Output
    
    style Input fill:#e3f2fd
    style Processing fill:#fff3e0
    style Output fill:#c8e6c9
```

---

## Dependency Graph (DAG)

Terraform builds a **Directed Acyclic Graph** to determine resource order.

### Example Infrastructure Graph

```mermaid
flowchart TD
    subgraph Graph["Resource Dependency Graph"]
        VPC["🌐 aws_vpc<br/>main"]
        
        Subnet["📦 aws_subnet<br/>public"]
        SG["🛡️ aws_security_group<br/>web"]
        IGW["🚪 aws_internet_gateway<br/>main"]
        
        RT["🗺️ aws_route_table<br/>public"]
        
        EC2["💻 aws_instance<br/>web"]
        
        EIP["📍 aws_eip<br/>web"]
    end
    
    VPC --> Subnet
    VPC --> SG
    VPC --> IGW
    
    Subnet --> RT
    IGW --> RT
    
    Subnet --> EC2
    SG --> EC2
    
    EC2 --> EIP
    
    style VPC fill:#bbdefb
    style Subnet fill:#c8e6c9
    style SG fill:#ffccbc
    style IGW fill:#fff9c4
    style RT fill:#d1c4e9
    style EC2 fill:#b2ebf2
    style EIP fill:#f8bbd9
```

### Parallel Execution

Resources without dependencies can be created **in parallel**.

```mermaid
flowchart LR
    subgraph Execution["Execution Order"]
        subgraph T1["Time 1"]
            VPC["VPC"]
        end
        
        subgraph T2["Time 2 (Parallel)"]
            Subnet["Subnet"]
            SG["Security Group"]
            IGW["Internet Gateway"]
        end
        
        subgraph T3["Time 3"]
            RT["Route Table"]
        end
        
        subgraph T4["Time 4"]
            EC2["EC2 Instance"]
        end
        
        subgraph T5["Time 5"]
            EIP["Elastic IP"]
        end
    end
    
    T1 --> T2 --> T3 --> T4 --> T5
    
    style T1 fill:#e3f2fd
    style T2 fill:#c8e6c9
    style T3 fill:#fff3e0
    style T4 fill:#f3e5f5
    style T5 fill:#fce4ec
```

### Implicit vs Explicit Dependencies

```mermaid
flowchart TB
    subgraph Implicit["🔗 Implicit Dependencies"]
        direction TB
        I1["Detected from references"]
        I2["subnet_id = aws_subnet.main.id"]
        I3["Automatic ordering"]
    end
    
    subgraph Explicit["📌 Explicit Dependencies"]
        direction TB
        E1["depends_on attribute"]
        E2["For hidden dependencies"]
        E3["Manual override"]
    end
    
    style Implicit fill:#e8f5e9
    style Explicit fill:#fff3e0
```

```hcl
# Implicit dependency - Terraform detects automatically
resource "aws_instance" "web" {
  subnet_id = aws_subnet.public.id  # ← Creates dependency
}

# Explicit dependency - You specify manually
resource "aws_instance" "app" {
  depends_on = [aws_iam_role_policy.s3_access]  # ← Hidden dependency
}
```

---

## Execution Plan

### Plan Generation Process

```mermaid
flowchart TD
    Start["terraform plan"]
    
    Start --> Read["1. Read Configuration<br/>Parse all .tf files"]
    Read --> Load["2. Load State<br/>Read terraform.tfstate"]
    Load --> Refresh["3. Refresh<br/>Query providers for current state"]
    Refresh --> Graph["4. Build Graph<br/>Create dependency DAG"]
    Graph --> Diff["5. Calculate Diff<br/>Compare desired vs actual"]
    Diff --> Plan["6. Generate Plan<br/>Determine actions"]
    Plan --> Output["📋 Execution Plan"]
    
    style Start fill:#90caf9
    style Output fill:#a5d6a7
```

### Plan Actions

```mermaid
flowchart LR
    subgraph Actions["Plan Action Types"]
        Create["➕ CREATE<br/>New resource"]
        Update["🔄 UPDATE<br/>Modify in-place"]
        Replace["♻️ REPLACE<br/>Destroy & recreate"]
        Destroy["🗑️ DESTROY<br/>Remove resource"]
    end
    
    style Create fill:#c8e6c9
    style Update fill:#fff9c4
    style Replace fill:#ffccbc
    style Destroy fill:#ffcdd2
```

---

## How `terraform apply` Works

```mermaid
sequenceDiagram
    participant User
    participant CLI as Terraform CLI
    participant Core as Terraform Core
    participant State as State Manager
    participant Provider as Provider Plugin
    participant API as Cloud API
    
    User->>CLI: terraform apply
    
    Note over Core,State: Phase 1: Load
    CLI->>Core: Start apply
    Core->>State: Load current state
    State-->>Core: State loaded
    
    Note over Core,Provider: Phase 2: Plan
    Core->>Provider: Refresh resources
    Provider->>API: Query current state
    API-->>Provider: Current attributes
    Provider-->>Core: Refreshed state
    Core->>Core: Calculate diff
    Core-->>CLI: Show plan
    
    Note over User,CLI: Phase 3: Confirm
    CLI-->>User: Proceed? (yes/no)
    User->>CLI: yes
    
    Note over Core,API: Phase 4: Execute
    loop For each resource (respecting dependencies)
        Core->>Provider: Apply change
        Provider->>API: CREATE/UPDATE/DELETE
        API-->>Provider: Result
        Provider-->>Core: New state
        Core->>State: Update state
    end
    
    Note over Core,State: Phase 5: Save
    Core->>State: Persist state
    State-->>Core: Saved
    Core-->>CLI: Complete
    CLI-->>User: Apply finished!
```

---

## Graph Walking Algorithm

```mermaid
flowchart TD
    Start["Start Graph Walk"]
    
    Start --> FindRoots["Find root nodes<br/>(no dependencies)"]
    FindRoots --> Process["Process nodes in parallel"]
    
    Process --> Execute["Execute operation"]
    Execute --> Mark["Mark as complete"]
    Mark --> Unblock["Unblock dependent nodes"]
    
    Unblock --> Check{"More nodes<br/>to process?"}
    Check -->|"Yes"| Process
    Check -->|"No"| Done["Walk complete"]
    
    style Start fill:#90caf9
    style Done fill:#a5d6a7
```

---

## Terraform Commands Flow

```mermaid
flowchart TB
    subgraph Commands["Terraform Commands"]
        Init["terraform init"]
        Plan["terraform plan"]
        Apply["terraform apply"]
        Destroy["terraform destroy"]
    end
    
    subgraph Init_Flow["init"]
        I1["Download providers"]
        I2["Initialize backend"]
        I3["Download modules"]
    end
    
    subgraph Plan_Flow["plan"]
        P1["Read config"]
        P2["Load state"]
        P3["Refresh"]
        P4["Generate plan"]
    end
    
    subgraph Apply_Flow["apply"]
        A1["Generate plan"]
        A2["Confirm"]
        A3["Execute changes"]
        A4["Update state"]
    end
    
    subgraph Destroy_Flow["destroy"]
        D1["Plan destruction"]
        D2["Confirm"]
        D3["Delete resources"]
        D4["Update state"]
    end
    
    Init --> I1 --> I2 --> I3
    Plan --> P1 --> P2 --> P3 --> P4
    Apply --> A1 --> A2 --> A3 --> A4
    Destroy --> D1 --> D2 --> D3 --> D4
    
    style Init fill:#4fc3f7
    style Plan fill:#ffb74d
    style Apply fill:#81c784
    style Destroy fill:#e57373
```

---

## Summary

```mermaid
mindmap
    root((Terraform<br/>Architecture))
        Configuration
            HCL Parser
            Expression Evaluator
            Module Loader
        State
            State Manager
            Backend Interface
            Locking
        Graph
            Graph Builder
            Dependency Resolution
            Parallel Execution
        Providers
            Plugin Protocol
            gRPC Communication
            CRUD Operations
        Plan/Apply
            Diff Engine
            Plan Generator
            Execution Engine
```

---

## Key Takeaways

1. **Declarative**: You define the desired state, Terraform figures out how
2. **Graph-Based**: Dependencies enable parallel execution
3. **Provider Plugins**: Separate processes communicate via gRPC
4. **State-Driven**: State tracks what Terraform manages
5. **Idempotent**: Same config = same result
