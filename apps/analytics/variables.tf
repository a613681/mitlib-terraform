variable "awslogs_region" {
  description = "awslogs_region"
  type        = string
}

variable "db_instance_type" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.micro"
}

variable "db_storage_size" {
  description = "Size of RDS database in GB"
  type        = number
}

variable "mysql_user" {
  description = "Database user"
  type        = string
}

variable "mysql_password" {
  description = "Database mysql_password"
  type        = string
}

variable "mysql_database" {
  description = "mysql_database"
  type        = string
}

variable "matomo_database_password" {
  description = "matomo_database_password"
  type        = string
}

variable "matomo_database_adapter" {
  description = "matomo_database_adapter"
  type        = string
}

variable "matomo_database_tables_prefix" {
  description = "matomo_database_tables_prefix"
  type        = string
}

variable "matomo_database_username" {
  description = "matomo_database_username"
  type        = string
}

variable "matomo_database_dbname" {
  description = "matomo_database_dbname"
  type        = string
}

variable "efs_kms_key_id" {
  description = "EBS kms_key_id"
  type        = string
}

variable "rds_kms_key_id" {
  description = "RDS kms_key_id"
  type        = string
}

variable "mount" {
  description = "efs mount dir"
  type        = string
}

variable "salt" {
  description = "installation salt"
  type        = string
}

# mail 

variable "noreply_email_address" {
  description = "noreply_email_address"
  type        = string
}

variable "smtp_port" {
  description = "smtp port"
  type        = string
}

variable "smtp_host" {
  description = "smtp_host"
  type        = string
}

variable "smtp_auth_type" {
  description = "smtp auth type"
  type        = string
}

variable "smtp_user" {
  description = "smtp user"
  type        = string
}

variable "smtp_password" {
  description = "smtp password"
  type        = string
}


