output "eip_public_address" {
  description = "Elasic IP address"
  value       = aws_eip.default.public_ip
}

output "hostname" {
  description = "Hostname of the Archivematica EC2 application server"
  value       = [aws_route53_record.default.*.fqdn]
}
