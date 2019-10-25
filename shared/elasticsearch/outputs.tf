output "es_arn" {
  description = "Domain-specific endpoint used to submit index, search, and data upload requests"
  value       = module.elasticsearch.arn
}

output "es_endpoint" {
  description = "Domain-specific endpoint used to submit index, search, and data upload requests"
  value       = module.elasticsearch.endpoint
}

output "read_policy_arn" {
  description = "Default domain read only policy ARN"
  value       = module.elasticsearch.read_policy_arn
}

output "write_policy_arn" {
  description = "Default domain write policy ARN"
  value       = module.elasticsearch.write_policy_arn
}

output "domain_name" {
  description = "Domain name of cluster"
  value       = module.elasticsearch.domain_name
}

