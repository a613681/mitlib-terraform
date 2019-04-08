output "deploy_user" {
  value       = "${aws_iam_user.deploy.name}"
  description = "Name of the IAM deploy user"
}

output "access_key_id" {
  value       = "${aws_iam_access_key.deploy.id}"
  description = "Access key for deploy user"
}

output "secret_access_key" {
  value       = "${aws_iam_access_key.deploy.secret}"
  description = "Secret key for deploy user"
  sensitive   = true
}
