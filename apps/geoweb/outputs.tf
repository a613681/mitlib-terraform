output "deploy_user" {
  value       = "${aws_iam_user.deploy.name}"
  description = "Name of the IAM deploy user"
}

output "access_key_id" {
  value       = "${aws_iam_access_key.deploy.id}"
  description = "Access key for deploy user"
}

output "secret_access_key" {
  value       = "${aws_iam_access_key.deploy.secret}"
  description = "Secret key for deploy user"
  sensitive   = true
}

output "gbl_downloader_user" {
  value       = "${aws_iam_user.gbl_downloader.name}"
  description = "Name of GBL downloader user"
}

output "gbl_downloader_key" {
  value       = "${aws_iam_access_key.gbl_downloader.id}"
  description = "GBL downloader access key"
}

output "gbl_downloader_secret" {
  value       = "${aws_iam_access_key.gbl_downloader.secret}"
  description = "GBL downloader secret key"
  sensitive   = true
}
