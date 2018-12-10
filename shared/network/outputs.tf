output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "private_subnets" {
  value = "${module.vpc.private_subnets}"
}

output "public_subnets" {
  value = "${module.vpc.public_subnets}"
}

output "alb_restricted_arn" {
  description = "Restricted ALB arn"
  value       = "${module.alb_restricted.alb_arn}"
}

output "alb_restricted_arn_suffix" {
  description = "The ARN suffix of the ALB"
  value       = "${module.alb_restricted.alb_arn_suffix}"
}

output "alb_restricted_name" {
  description = "Restricted ALB name"
  value       = "${module.alb_restricted.alb_name}"
}

output "alb_restricted_dnsname" {
  description = "Restricted ALB DNS name"
  value       = "${module.alb_restricted.alb_dns_name}"
}

output "alb_restricted_sgid" {
  description = "Restricted ALB security group ID"
  value       = "${module.alb_restricted.security_group_id}"
}

output "alb_restricted_default_target_group_arn" {
  description = "Restricted ALB default target group arn"
  value       = "${module.alb_restricted.default_target_group_arn}"
}

output "alb_restricted_http_listener_arn" {
  description = "Restricted ALB HTTP listener ARN"
  value       = "${module.alb_restricted.http_listener_arn}"
}

output "alb_restricted_https_listener_arn" {
  description = "Restricted ALB HTTPS listener ARN"
  value       = "${module.alb_restricted.https_listener_arn}"
}
