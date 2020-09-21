variable "r53_haydenrenonews_value" {
  description = "The prod haydenrenonews.mitlib.net website DNS CNAME record value"
  type        = list(string)
}

variable "r53_haydenrenonews_dev_value" {
  description = "The haydenrenonews-dev.mitlib.net website DNS CNAME record value"
  type        = list(string)
}

variable "r53_haydenrenonews_test_value" {
  description = "The haydenrenonews-test.mitlib.net website DNS CNAME record value"
  type        = list(string)
}
