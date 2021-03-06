output "bucket_name" {
  value       = module.bucket.bucket_id
  description = "Name of Lambda bucket"
}

output "deploy_user" {
  value       = aws_iam_user.default.name
  description = "Name of the IAM deploy user"
}

output "access_key_id" {
  value       = aws_iam_access_key.default.id
  description = "Access key for deploy user"
}

output "secret_access_key" {
  value       = aws_iam_access_key.default.secret
  description = "Secret key for deploy user"
  sensitive   = true
}

output "role_arn" {
  value       = aws_iam_role.default.arn
  description = "ARN for Zappa execution role"
}

output "secrets_arn" {
  value       = module.secret.secret
  description = "ARN for author lookup secrets"
}

