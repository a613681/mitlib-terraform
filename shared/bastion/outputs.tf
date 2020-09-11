# Public IP of the bastion host
output "eip_public_address" {
  description = "Elastic IP address"
  value       = aws_eip.bastion.public_ip
}

# Bastion host Security Group ID
output "ingress_from_bastion_sg_id" {
  description = "Bastion host Security Group ID"
  value       = module.bastion.security_group_id
}
