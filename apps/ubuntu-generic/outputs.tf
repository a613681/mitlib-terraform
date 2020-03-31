
output "public_ip" {
  value       = aws_instance.default.public_ip
  description = "The public IP address of the web server"
}
