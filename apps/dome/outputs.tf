output "eip_public_address" {
  value       = "${aws_eip.default.public_ip}"
  description = "Elasic IP address"
}
