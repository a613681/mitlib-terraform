
# app
output "app_private_ips" {
  value       = aws_instance.app.private_ip
  description = "The app private_ips"
}

output "app_private_fqdn" {
  value       = aws_route53_record.app_priv.*.fqdn
  description = "The app private fqdn"
}

output "app_public_fqdn" {
  value       = aws_route53_record.app.*.fqdn
  description = "The app public fqdn"
}

