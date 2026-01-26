# ===========================================
# Main Terraform Configuration
# ===========================================
# This file contains the main resources for
# our EC2 infrastructure.
# ===========================================

# -----------------------------------------
# Data Sources
# -----------------------------------------
# Data sources query existing infrastructure
# for read-only information.

# Get the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Get available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# -----------------------------------------
# Local Values
# -----------------------------------------
# Locals are computed values used within
# the configuration.

locals {
  common_tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}"
      Environment = var.environment
      Project     = var.project_name
      Owner       = var.owner
    },
    var.extra_tags
  )
}

# ===========================================
# NETWORK RESOURCES
# ===========================================

# -----------------------------------------
# VPC
# -----------------------------------------
# The VPC is the foundation of our network.
# All other network resources depend on it.

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-vpc"
  })
}

# -----------------------------------------
# Internet Gateway
# -----------------------------------------
# Allows internet access for resources in
# public subnets.
# DEPENDENCY: Requires VPC

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id  # Implicit dependency on VPC

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-igw"
  })
}

# -----------------------------------------
# Public Subnet
# -----------------------------------------
# Subnet where our EC2 instance will live.
# DEPENDENCY: Requires VPC

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id  # Implicit dependency
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = var.enable_public_ip

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-subnet"
    Type = "Public"
  })
}

# -----------------------------------------
# Route Table
# -----------------------------------------
# Defines routing rules for the subnet.
# DEPENDENCIES: Requires VPC and Internet Gateway

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id  # Implicit dependency on IGW
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-rt"
  })
}

# -----------------------------------------
# Route Table Association
# -----------------------------------------
# Associates the route table with the subnet.
# DEPENDENCIES: Requires Subnet and Route Table

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ===========================================
# SECURITY RESOURCES
# ===========================================

# -----------------------------------------
# Security Group
# -----------------------------------------
# Firewall rules for our EC2 instance.
# DEPENDENCY: Requires VPC

resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Security group for web server"
  vpc_id      = aws_vpc.main.id

  # Inbound Rules
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  # Outbound Rules
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-web-sg"
  })
}

# ===========================================
# COMPUTE RESOURCES
# ===========================================

# -----------------------------------------
# EC2 Instance
# -----------------------------------------
# The web server instance.
# DEPENDENCIES: Requires Subnet, Security Group

resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]

  # User data script runs on first boot
  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y httpd
              systemctl start httpd
              systemctl enable httpd
              
              # Create a simple web page
              cat > /var/www/html/index.html << 'HTML'
              <!DOCTYPE html>
              <html>
              <head>
                  <title>Terraform Demo</title>
                  <style>
                      body { font-family: Arial; text-align: center; padding: 50px; }
                      h1 { color: #5C4EE5; }
                      .info { background: #f5f5f5; padding: 20px; margin: 20px auto; max-width: 600px; border-radius: 8px; }
                  </style>
              </head>
              <body>
                  <h1>🚀 Hello from Terraform!</h1>
                  <div class="info">
                      <p>This EC2 instance was provisioned using <strong>Terraform</strong></p>
                      <p>Infrastructure as Code makes deployments repeatable and version-controlled.</p>
                  </div>
              </body>
              </html>
              HTML
              EOF

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.instance_name}"
  })
}

# -----------------------------------------
# Elastic IP (Optional)
# -----------------------------------------
# Static public IP for the instance.
# DEPENDENCY: Requires EC2 Instance and IGW

resource "aws_eip" "web" {
  instance = aws_instance.web.id
  domain   = "vpc"

  # Explicit dependency: EIP needs IGW for internet access
  depends_on = [aws_internet_gateway.main]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-web-eip"
  })
}
