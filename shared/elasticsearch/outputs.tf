output "es_arn" {
  description = "Domain-specific endpoint used to submit index, search, and data upload requests"
  value       = "${module.elasticsearch.arn}"
}

output "es_endpoint" {
  description = "Domain-specific endpoint used to submit index, search, and data upload requests"
  value       = "${module.elasticsearch.endpoint}"
}
