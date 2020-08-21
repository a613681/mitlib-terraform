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

# RDS resource module related variables
variable "rds_engine" {
  type        = string
  description = "RDS database engine"
}

variable "rds_maj_eng_ver" {
  type        = string
  description = "RDS database engine major version"
}

variable "rds_eng_ver" {
  type        = string
  description = "RDS database engine version"
}

variable "rds_maj_upgrade" {
  type        = string
  description = "Allow automated RDS database major engine version upgrade"
}

variable "rds_apply_immediately" {
  type        = string
  description = "Apply database modifications immediately or during next maintenance window"
}

variable "rds_inst_class" {
  type        = string
  description = "Class of the RDS instance"
}

variable "rds_storage" {
  type        = string
  description = "The amount of storage for the RDS instance in GB"
}

variable "rds_db_name" {
  type        = string
  description = "The RDS database name"
}

variable "rds_port" {
  type        = string
  description = "The TCP port for the RDS instance to use"
}

variable "rds_param_grp" {
  type        = string
  default     = ""
  description = "The RDS parameter group to use with the RDS database"
}

variable "rds_maint_win" {
  type        = string
  default     = ""
  description = "RDS maintenance window"
}

variable "rds_backup_win" {
  type        = string
  default     = ""
  description = "RDS database backup window"
}

variable "rds_backup_retain" {
  type        = string
  default     = "0"
  description = "RDS backup retention period"
}

variable "rds_username" {
  type        = string
  description = "Username for the master DB user"
}

variable "rds_password" {
  type        = string
  description = "Password for the master DB user"
}

variable "rds_subnets" {
  type        = list(string)
  default     = []
  description = "Subnet to use for RDS DB"
}

# EFS Vars
variable "efs_subnet" {
  description = "The subnet for the EFS mount target"
  type        = string
  default     = ""
}

variable "efs_mount" {
  description = "The EFS mount for the assetstore"
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
  type        = number
  default     = 0
}

# Security Group variables
variable "sec_handle_access_subnets" {
  description = "Subnets to allow Handle server access"
  type        = list(string)
  default     = []
}

variable "sec_ssh_access_subnets" {
  description = "Subnets to allow SSH access"
  type        = list(string)
  default     = []
}

variable "sec_web_access_subnets" {
  description = "Subnets to allow access to the Dome web UI"
  type        = list(string)
  default     = []
}
