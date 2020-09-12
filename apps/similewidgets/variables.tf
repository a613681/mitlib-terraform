# Route53 variables
variable "r53_api_value" {
  description = "The api.simile-widgets.org website DNS record value"
  type        = list(string)
}

variable "r53_service_value" {
  description = "The service.simile-widgets.org website DNS record value"
  type        = list(string)
}

variable "r53_trunk_value" {
  description = "The trunk.simile-widgets.org website DNS record value"
  type        = list(string)
}

variable "r53_web_value" {
  description = "The simile-widgets.org website DNS record value"
  type        = list(string)
}
