

output "private_ip" {
  value       = aws_instance.default.private_ip
  description = "The public IP address of the web server"
}




