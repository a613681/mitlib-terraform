variable "r53_fol_value" {
  description = "The prod future-of-libraries.mitlib.net website DNS CNAME record value"
  type        = list(string)
}

variable "r53_fol_dev_value" {
  description = "The future-of-libraries-dev.mitlib.net website DNS CNAME record value"
  type        = list(string)
}

variable "r53_fol_test_value" {
  description = "The future-of-libraries-test.mitlib.net website DNS CNAME record value"
  type        = list(string)
}
