# EC2 variables
variable "ec2_ami" {
  description = "The AMI to use for the EC2 instance"
  type        = string
  default     = ""
}

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

variable "ec2_subnet" {
  description = "Subnet to use for the EC2 instance IP address"
  type        = string
  default     = ""
}

variable "ec2_vol_size" {
  description = "The EC2 volume size to use for the instance"
  type        = string
  default     = ""
}

variable "ec2_vol_type" {
  description = "The EC2 volume type to use for the instance"
  type        = string
  default     = ""
}


# EFS variables
variable "efs_mount" {
  description = "The location on the EC2 server to mount the EFS instance"
  type        = string
  default     = ""
}

variable "efs_subnet" {
  description = "The subnet to use for the EFS mount target"
  type        = string
  default     = ""
}


# Route53 variables

variable "r53_dns_zone_id" {
  description = "The ID of the zone in which to create the DNS record"
  type        = string
  default     = ""
}

variable "r53_enabled" {
  description = "Enable or disable Route53 changes"
  default     = "true"
}


# Security Group variables
variable "sec_ss_access_subnets" {
  description = "Subnets to allow access to the Archivematica Storage Service web UI"
  type        = list(string)
  default     = []
}

variable "sec_ssh_access_subnets" {
  description = "Subnets to allow SSH access"
  type        = list(string)
  default     = []
}

variable "sec_web_access_subnets" {
  description = "Subnets to allow access to the Archivematica web UI"
  type        = list(string)
  default     = []
}
