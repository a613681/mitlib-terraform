output "bucket_arn" {
  value       = aws_s3_bucket.default.arn
  description = "ARN of the S3 bucket"
}

output "bucket_name" {
  value       = aws_s3_bucket.default.id
  description = "Name (ID) of the S3 bucket"
}

output "deploy_user" {
  value       = aws_iam_user.deploy.name
  description = "Deploy user with R/W ECR permissions"
}
