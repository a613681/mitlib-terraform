output "access_key_id" {
  value       = "${aws_iam_access_key.default.id}"
  description = "The access key ID"
}

output "secret_access_key" {
  value       = "${aws_iam_access_key.default.secret}"
  sensitive   = true
  description = "The secret access key. This will be written to the state file in plain-text"
}
