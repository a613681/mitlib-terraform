output "deploy_user" {
  value       = aws_iam_user.deploy.name
  description = "Name of the IAM deploy user"
}

