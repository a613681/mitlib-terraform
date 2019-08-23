variable "rds_username" {
  type        = "string"
  default     = ""
  description = "(Required unless a `snapshot_identifier` or `replicate_source_db` is provided) Username for the master DB user"
}

variable "rds_password" {
  type        = "string"
  default     = ""
  description = "(Required unless a snapshot_identifier or replicate_source_db is provided) Password for the master DB user"
}

variable "cybersource_access_key" {
  type        = "string"
  default     = ""
  description = "Identifier passed to MIT Merchant Services to ensure payments are classified correctly"
}

variable "cybersource_profile_id" {
  type        = "string"
  default     = ""
  description = "Identifier passed to MIT Merchant Services to ensure payments are classified correctly"
}

variable "mail_host" {
  type        = "string"
  description = "Hostname of external SMTP email server"
}

variable "mail_password" {
  type        = "string"
  description = "Password associated with account used to send email"
}

variable "mail_port" {
  type        = "string"
  description = "Port used to connect to external SMTP email server"
}

variable "mail_username" {
  type        = "string"
  description = "Username associated with account used to send email"
}
