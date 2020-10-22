output "fqdn" {
  value       = aws_route53_record.default.fqdn
  description = "Route 53 domain name"
}

output "efs" {
  value       = aws_efs_file_system.default.arn
  description = "EFS ARN"
}
