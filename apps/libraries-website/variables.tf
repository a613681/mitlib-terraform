# RDS resource module related variables
variable rds_username {
  type        = "string"
  description = "MariaDB username"
}

variable rds_password {
  type        = "string"
  description = "MariaDB password"
}

# Route53 resource module related variables
variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  default     = "true"
}

variable "dns_zone_id" {
  type        = "string"
  default     = ""
  description = "The ID of the DNS Zone in Route53 where a new DNS record will be created for the DB host name"
}
