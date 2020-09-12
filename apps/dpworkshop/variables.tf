# Route53 variables
variable "r53_dpworkshop_prod_value" {
  description = "The prod dpworkshop.org website DNS record value"
  type        = list(string)
}

variable "r53_dpworkshop_prod_ipv6_value" {
  description = "The prod dpworkshop.org website IPv6 DNS record value"
  type        = list(string)
}

variable "r53_dpworkshop_dev_value" {
  description = "The dev.dpworkshop.org website DNS CNAME record value"
  type        = list(string)
}

variable "r53_dpworkshop_test_value" {
  description = "The test.dpworkshop.org website DNS CNAME record value"
  type        = list(string)
}

variable "r53_tdr_value" {
  description = "The prod tdr.dpworkshop.org Trac website DNS CNAME record value"
  type        = list(string)
}

variable "r53_tdr_dev_value" {
  description = "The tdr-dev.dpworkshop.org Trac website DNS CNAME record value"
  type        = list(string)
}

variable "r53_tdr_test_value" {
  description = "The tdr-test.dpworkshop.org Trac website DNS CNAME record value"
  type        = list(string)
}
