# MIT Merchant Services Integration Variables
variable "cybersource_access_key" {
  type        = string
  description = "Identifier passed to MIT Merchant Services to ensure payments are classified correctly"
}

variable "cybersource_profile_id" {
  type        = string
  description = "Identifier passed to MIT Merchant Services to ensure payments are classified correctly"
}

# EB Variables
variable "eb_instance_class" {
  type        = string
  description = "The class of the EB instance"
}

variable "eb_solution_stack" {
  type        = string
  description = "The solution stack used to to build the EB instance"
}

# MIT Email System Integration Variables
variable "mail_host" {
  type        = string
  description = "Hostname of external SMTP email server"
}

variable "mail_username" {
  type        = string
  description = "Username associated with account used to send email"
}

variable "mail_password" {
  type        = string
  description = "Password associated with account used to send email"
}

variable "mail_port" {
  type        = string
  description = "Port used to connect to external SMTP email server"
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

# Shell Access Variables
variable "ssh_keypair" {
  type        = string
  description = "SSH Keypair allowed shell login access"
}

variable "ssh_subnet_restriction" {
  type        = string
  description = "CIDR subnet mask for network allowed to connect over ssh"
}
