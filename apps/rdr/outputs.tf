# zk
output "zk_private_ips" {
  value       = aws_instance.zookeeper_cluster[*].private_ip
  description = "The zk private_ips"
}

output "zk_private_fqdn" {
  value       = aws_route53_record.zookeeper.*.fqdn
  description = "The zk private fqdn"
}
# solr
output "solr_private_ips" {
  value       = aws_instance.solr_cluster[*].private_ip
  description = "The solr private_ips"
}

output "solr_private_fqdn" {
  value       = aws_route53_record.solr.*.fqdn
  description = "The solr private fqdn"
}
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
