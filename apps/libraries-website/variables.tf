# Global variables
variable "vpc_id" {
  type        = string
  description = "VPC to build infrastructure in"
}

variable "ec2_subnet" {
  type        = string
  description = "Subnet to use for ec2 host"
}

# RDS resource module related variables
variable "rds_username" {
  type        = string
  description = "MariaDB username"
}

variable "rds_password" {
  type        = string
  description = "MariaDB password"
}

variable "rds_subnets" {
  type        = list(string)
  default     = []
  description = "Subnet to use for RDS db"
}

# Route53 resource module related variables
variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  default     = "true"
}

variable "dns_zone_id" {
  type        = string
  default     = ""
  description = "The ID of the DNS Zone in Route53 where a new DNS record will be created for the DB host name"
}

# EFS Vars
variable "efs_subnet" {
  type        = string
  default     = ""
  description = "The subnet for the EFS mount target"
}

variable "mount" {
  type        = string
  default     = ""
  description = "The EFS mount for the assetstore"
}

