# ec2 Vars
variable subnet {
  type        = "string"
  description = "VPC Subnet for ec2 host"
}

# RDS resource module related variables
variable rds_username {
  type        = "string"
  description = "Postgres username"
}

variable rds_password {
  type        = "string"
  description = "Postgres password"
}

variable rds_dbname {
  type        = "string"
  description = "Alphanumeric database name"
}

# Route53 resource module related variables
variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  default     = "true"
}

variable "dns_zone_id" {
  type        = "string"
  default     = ""
  description = "The ID of the DNS Zone in Route53"
}

# EFS Vars

variable "efs_subnet" {
  type        = "string"
  default     = ""
  description = "The subnet for the EFS mount target"
}

variable "mount" {
  type        = "string"
  default     = ""
  description = "The EFS mount for the assetstore"
}
