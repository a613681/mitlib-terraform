variable "r53_trac_value" {
  description = "The prod tdr.mitlib.net Trac website DNS CNAME record value"
  type        = list(string)
}

variable "r53_trac_dev_value" {
  description = "The tdr-dev.mitlib.net Trac website DNS CNAME record value"
  type        = list(string)
}

variable "r53_trac_test_value" {
  description = "The tdr-test.mitlib.net Trac website DNS CNAME record value"
  type        = list(string)
}
