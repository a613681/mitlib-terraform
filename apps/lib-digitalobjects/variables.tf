variable "acm_certificate_arn" {
  type        = "string"
  default     = ""
  description = "ACM Certificate ARN for Cloudfront (the .mit.edu cert)"
}

variable "ext_aliases" {
  type        = "list"
  default     = [""]
  description = "List of external aliases for the Cloudfront Distribution and CORS Origins (.mit.edu DNS)"
}
