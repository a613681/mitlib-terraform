output "mysql_hostname" {
  value       = aws_db_instance.default.address
  description = "MYSQL hostname"
}