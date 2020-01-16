variable "users" {
  description = "A list of IAM usernames that should have access to the bucket"
  type        = list(string)
  default     = []
}
