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

variable "ssl_email" {
  type        = "string"
  default     = ""
  description = "E-mail Address to use for registration with Let's Encrypt"
}
