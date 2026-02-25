# ===========================================
# Output Values
# ===========================================

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.web.private_ip
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.ec2.id
}

output "ami_id" {
  description = "AMI ID used"
  value       = data.aws_ami.amazon_linux.id
}

output "ssh_command" {
  description = "SSH command to connect"
  value       = "ssh -i <your-key.pem> ec2-user@${aws_instance.web.public_ip}"
}
