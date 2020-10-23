output "role_arn" {
  description = "ARN of cloudcheckr role."
  value       = aws_iam_role.cloudcheckr_role.arn
}
