# ===========================================
# Output Values
# ===========================================
# Outputs expose information about your
# infrastructure after terraform apply.
# 
# Use cases:
# - Display important values (IPs, URLs)
# - Pass data between modules
# - Query with: terraform output
# ===========================================

# -----------------------------------------
# Network Outputs
# -----------------------------------------

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

# -----------------------------------------
# Security Outputs
# -----------------------------------------

output "security_group_id" {
  description = "ID of the web security group"
  value       = aws_security_group.web.id
}

# -----------------------------------------
# Compute Outputs
# -----------------------------------------

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "instance_private_ip" {
  description = "Private IP address of the instance"
  value       = aws_instance.web.private_ip
}

output "instance_public_ip" {
  description = "Public IP address (Elastic IP)"
  value       = aws_eip.web.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the instance"
  value       = aws_instance.web.public_dns
}

# -----------------------------------------
# Useful URLs
# -----------------------------------------

output "web_url" {
  description = "URL to access the web server"
  value       = "http://${aws_eip.web.public_ip}"
}

output "ssh_command" {
  description = "SSH command to connect (add your key)"
  value       = "ssh -i <your-key.pem> ec2-user@${aws_eip.web.public_ip}"
}

# -----------------------------------------
# AMI Information
# -----------------------------------------

output "ami_id" {
  description = "AMI ID used for the instance"
  value       = data.aws_ami.amazon_linux.id
}

output "ami_name" {
  description = "Name of the AMI used"
  value       = data.aws_ami.amazon_linux.name
}
