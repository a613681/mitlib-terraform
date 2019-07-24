output "fqdn" {
  value       = "${aws_route53_record.default.fqdn}"
  description = "Route 53 domain name"
}
