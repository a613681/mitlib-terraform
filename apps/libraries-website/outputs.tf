output "website_hostname" {
  value       = ["aws_route53_record.libraries-website.*.fqdn"]
  description = "Hostname of the webserver"
}

