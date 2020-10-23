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
# efs solrs
output "efs-file-system-solrs-dns-name" {
  value = aws_efs_file_system.solrs_data_backup.dns_name
}

output "efs-mount-target-solrs-dns-name" {
  value = aws_efs_mount_target.solrs_data_mount.*.dns_name
}
# efs zookeepers
output "efs-file-system-zookeepers-dns-name" {
  value = aws_efs_file_system.zookeepers_data_backup.dns_name
}

output "efs-mount-target-zookeepers-dns-name" {
  value = aws_efs_mount_target.zookeepers_data_mount.*.dns_name
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
# rds
output "postgress_hostname" {
  value       = aws_db_instance.default.address
  description = "Database hostname"
}

output "postgress_fqdn" {
  value       = aws_route53_record.rds.fqdn
  description = "Database hostname"
}
