output "postgres_hostname" {
  value       = aws_db_instance.default.address
  description = "PostgreSQL hostname"
}

output "deploy_user" {
  value       = "${aws_iam_user.deploy.name}"
  description = "Name of the IAM deploy user"
}

output "oaiharvester_ecr_url" {
  value       = module.oaiharvester_ecr.registry_url
  description = "OAI Harvester ECR URL"
}
