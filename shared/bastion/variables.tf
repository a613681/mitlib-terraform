variable "name" {
  description = "Name to be used on all the resources as identifier"
  default     = ""
}

variable "aws_region" {
  description = "AWS region to be used for resources"
  default     = "us-east-1"
}

variable "logzio_token" {
  description = "Secret logz.io token for shipping logs to our account"
}

