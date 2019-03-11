output "role_arn" {
  description = "Role ARN of cloudcheckr role"
  value       = "${aws_iam_role.cloudcheckr_role.arn}"
}
