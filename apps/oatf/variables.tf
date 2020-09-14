variable "r53_oatf_value" {
  description = "The prod open-access.mitlib.net website DNS CNAME record value"
  type        = list(string)
}

variable "r53_oatf_dev_value" {
  description = "The open-access-dev.mitlib.net website DNS CNAME record value"
  type        = list(string)
}

variable "r53_oatf_test_value" {
  description = "The open-access-test.mitlib.net website DNS CNAME record value"
  type        = list(string)
}
