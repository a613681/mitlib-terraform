#######################
##### VPC OUTPUTS #####
#######################

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of VPC private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of VPC public subnets"
  value       = module.vpc.public_subnets
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_public_ips
}

######################
#####ALB OUTPUTS #####
######################

# Restricted
output "alb_restricted_arn" {
  description = "Restricted ALB arn"
  value       = module.alb_restricted.alb_arn
}

output "alb_restricted_arn_suffix" {
  description = "The ARN suffix of the ALB"
  value       = module.alb_restricted.alb_arn_suffix
}

output "alb_restricted_name" {
  description = "Restricted ALB name"
  value       = module.alb_restricted.alb_name
}

output "alb_restricted_dnsname" {
  description = "Restricted ALB DNS name"
  value       = module.alb_restricted.alb_dns_name
}

output "alb_restricted_sgid" {
  description = "Restricted ALB security group ID"
  value       = module.alb_restricted.security_group_id
}

output "alb_restricted_default_target_group_arn" {
  description = "Restricted ALB default target group arn"
  value       = module.alb_restricted.default_target_group_arn
}

output "alb_restricted_http_listener_arn" {
  description = "Restricted ALB HTTP listener ARN"
  value       = module.alb_restricted.http_listener_arn
}

output "alb_restricted_https_listener_arn" {
  description = "Restricted ALB HTTPS listener ARN"
  value       = module.alb_restricted.https_listener_arn
}

output "alb_restricted_all_ingress_sgid" {
  description = "Restricted ALB security group ID allowing all ingress traffic from ALB"
  value       = module.all_access_from_alb.this_security_group_id
}

output "alb_restricted_zone_id" {
  description = "Restricted ALB zone id"
  value       = module.alb_restricted.alb_zone_id
}

# Public
output "alb_public_arn" {
  description = "Public ALB arn"
  value       = module.alb_public.alb_arn
}

output "alb_public_arn_suffix" {
  description = "The ARN suffix of the ALB"
  value       = module.alb_public.alb_arn_suffix
}

output "alb_public_name" {
  description = "Public ALB name"
  value       = module.alb_public.alb_name
}

output "alb_public_dnsname" {
  description = "Public ALB DNS name"
  value       = module.alb_public.alb_dns_name
}

output "alb_public_sgid" {
  description = "Public ALB security group ID"
  value       = module.alb_public.security_group_id
}

output "alb_public_default_target_group_arn" {
  description = "Public ALB default target group arn"
  value       = module.alb_public.default_target_group_arn
}

output "alb_public_http_listener_arn" {
  description = "Public ALB HTTP listener ARN"
  value       = module.alb_public.http_listener_arn
}

output "alb_public_https_listener_arn" {
  description = "Public ALB HTTPS listener ARN"
  value       = module.alb_public.https_listener_arn
}

output "alb_public_all_ingress_sgid" {
  description = "Public ALB security group ID allowing all ingress traffic from ALB"
  value       = module.all_access_from_alb_public.this_security_group_id
}

output "alb_public_zone_id" {
  description = "Public ALB zone id"
  value       = module.alb_public.alb_zone_id
}

##############################
##### MITnet ALB OUTPUTS #####
##############################

# MITnet Restricted
output "mitnet_alb_restricted_arn" {
  description = "Restricted ALB arn"
  value       = module.mitnet_alb_restricted.alb_arn
}

output "mitnet_alb_restricted_arn_suffix" {
  description = "The ARN suffix of the ALB"
  value       = module.mitnet_alb_restricted.alb_arn_suffix
}

output "mitnet_alb_restricted_name" {
  description = "Restricted ALB name"
  value       = module.mitnet_alb_restricted.alb_name
}

output "mitnet_alb_restricted_dnsname" {
  description = "Restricted ALB DNS name"
  value       = module.mitnet_alb_restricted.alb_dns_name
}

output "mitnet_alb_restricted_sgid" {
  description = "Restricted ALB security group ID"
  value       = module.mitnet_alb_restricted.security_group_id
}

output "mitnet_alb_restricted_default_target_group_arn" {
  description = "Restricted ALB default target group arn"
  value       = module.mitnet_alb_restricted.default_target_group_arn
}

output "mitnet_alb_restricted_http_listener_arn" {
  description = "Restricted ALB HTTP listener ARN"
  value       = module.mitnet_alb_restricted.http_listener_arn
}

output "mitnet_alb_restricted_https_listener_arn" {
  description = "Restricted ALB HTTPS listener ARN"
  value       = module.mitnet_alb_restricted.https_listener_arn
}

output "mitnet_alb_restricted_all_ingress_sgid" {
  description = "Restricted ALB security group ID allowing all ingress traffic from ALB"
  value       = module.mitnet_all_access_from_alb.this_security_group_id
}

output "mitnet_alb_restricted_zone_id" {
  description = "Restricted ALB zone id"
  value       = module.mitnet_alb_restricted.alb_zone_id
}

# MITnet Public
output "mitnet_alb_public_arn" {
  description = "Public ALB arn"
  value       = module.mitnet_alb_public.alb_arn
}

output "mitnet_alb_public_arn_suffix" {
  description = "The ARN suffix of the ALB"
  value       = module.mitnet_alb_public.alb_arn_suffix
}

output "mitnet_alb_public_name" {
  description = "Public ALB name"
  value       = module.mitnet_alb_public.alb_name
}

output "mitnet_alb_public_dnsname" {
  description = "Public ALB DNS name"
  value       = module.mitnet_alb_public.alb_dns_name
}

output "mitnet_alb_public_sgid" {
  description = "Public ALB security group ID"
  value       = module.mitnet_alb_public.security_group_id
}

output "mitnet_alb_public_default_target_group_arn" {
  description = "Public ALB default target group arn"
  value       = module.mitnet_alb_public.default_target_group_arn
}

output "mitnet_alb_public_http_listener_arn" {
  description = "Public ALB HTTP listener ARN"
  value       = module.mitnet_alb_public.http_listener_arn
}

output "mitnet_alb_public_https_listener_arn" {
  description = "Public ALB HTTPS listener ARN"
  value       = module.mitnet_alb_public.https_listener_arn
}

output "mitnet_alb_public_all_ingress_sgid" {
  description = "Public ALB security group ID allowing all ingress traffic from ALB"
  value       = module.mitnet_all_access_from_alb_public.this_security_group_id
}

output "mitnet_alb_public_zone_id" {
  description = "Public ALB zone id"
  value       = module.mitnet_alb_public.alb_zone_id
}