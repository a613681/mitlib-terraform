# Global variables
variable "ec2_ami" {
  description = "The AMI to use for the EC2 instance"
  type        = string
  default     = ""
}

variable "ec2_subnet" {
  description = "Subnet to use for EC2 instance"
  type        = string
  default     = ""
}

# Security variables
variable "access_subnets" {
  description = "Subnets to allow TCP/IP access"
  type        = list(string)
  default     = []

}

# Route53 variables
variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  default     = "true"
}

variable "dns_zone_id" {
  description = "The ID of the DNS Zone in Route53 where a new DNS record will be created"
  type        = string
  default     = ""
}

# EFS variables
variable "efs_subnet" {
  description = "The subnet for the EFS mount target"
  type        = string
  default     = ""
}

variable "mount" {
  description = "The location on the EC2 server to mount the EFS instance"
  type        = string
  default     = ""
}
