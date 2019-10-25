output "access_key_id" {
  value       = aws_iam_access_key.default.id
  description = "Access key ID for the Aleph submission to S3 user"
}

output "secret_access_key" {
  value       = aws_iam_access_key.default.secret
  sensitive   = true
  description = "Secret access key for Aleph submission to S3 user"
}

output "mario_deploy_access_key_id" {
  value       = aws_iam_access_key.mario_deploy.id
  description = "Access key ID for the mario deploy user"
}

output "mario_deploy_secret_access_key" {
  value       = aws_iam_access_key.mario_deploy.secret
  sensitive   = true
  description = "Secret access key for mario deploy user."
}

output "timdex_access_key_secret" {
  value       = aws_iam_access_key.timdex.secret
  sensitive   = true
  description = "Secret access key for timdex user."
}

output "timdex_access_key_id" {
  value       = aws_iam_access_key.timdex.id
  sensitive   = true
  description = "ID for timdex user."
}

