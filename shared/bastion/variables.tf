# AWS variables
variable "aws_region" {
  description = "AWS region to be used for resources"
  type        = string
  default     = "us-east-1"
}

# EC2 variables
variable "ec2_inst_type" {
  description = "The instance type for the EC2 instance"
  type        = string
  default     = ""
}

variable "ec2_key_name" {
  description = "SSH key to assign to the EC2 instance"
  type        = string
  default     = ""
}

# logz.io variables
variable "logzio_token" {
  description = "Secret logz.io API token for shipping logs"
  type        = string
  default     = ""
}

# Route53 variables
variable "r53_dns_zone_id" {
  description = "The ID of the zone in which to create the DNS record"
  type        = string
  default     = ""
}

# Security Group variables
variable "sec_ssh_access_subnets" {
  description = "Subnets to allow SSH access"
  type        = list(string)
  default     = []
}

variable "sec_ssh_public_keys" {
  description = "List of SSH public keys from the S3 bucket to allow access"
  type        = string
  default     = ""
}
