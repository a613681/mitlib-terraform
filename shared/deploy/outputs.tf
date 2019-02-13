output "name" {
  value       = "${module.bucket.bucket_id}"
  description = "Bucket name"
}

output "rw_arn" {
  value       = "${module.bucket.readwrite_arn}"
  description = "Read/write policy ARN"
}
