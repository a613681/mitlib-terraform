variable "aws_region" {
  default = "us-east-1"
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  default     = ""
}

variable "cidr" {
  description = "The CIDR block for the VPC which will be created if `vpc_id` is not specified"
  default     = ""
}

variable "azs" {
  description = "A list of availability zones in the region"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "alb_cidrs" {
  description = "MIT's CIDR range. Used to restrict access to on campus/VPN IP's"
  default     = ["0.0.0.0/0"]
}

