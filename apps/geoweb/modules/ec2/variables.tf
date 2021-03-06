variable "name" {
  type = string
}

variable "mount" {
  type = string
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "security_groups" {
  type        = list
  default     = []
  description = "Security group IDs to associate with the EC2 instance."
}

variable "subnet" {
  type        = string
  description = "Subnet ID to deploy instance to."
}

variable "key_name" {
  type        = string
  description = "Name of keypair to add to instance"
}

variable "zone" {
  type        = string
  description = "DNS zone ID to register domain name in"
}

variable "vpc" {
  type        = string
  description = "VPC ID to deploy to"
}

variable "instance_profile" {
  type        = string
  description = "IAM instance profile to attach to instance"
  default     = ""
}
