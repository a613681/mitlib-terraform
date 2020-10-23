variable "ami" {
  description = "Instance ami"
  type        = string
}

variable "key_name" {
  description = "EC2 instance launch key name"
  type        = string
}

variable "ssh_user" {
  description = "SSH user to access EC2 instance"
  type        = string
}

variable "s3_bucket_pubkeys" {
  description = "S3 bucket containing public SSH keys"
  type        = string
}

variable "s3_bucket_pubkeys_uri" {
  description = "URI of S3 bucket containing public SSH keys"
  type        = string
}

variable "volume_size" {
  description = "EC2 volume size"
  type        = number
}

variable "volume_type" {
  description = "EC2 volume type"
  type        = string
}

variable "zookeeper_instance_type" {
  description = "Zookeeper instance type"
  type        = string
}

variable "zookeeper_instance_count" {
  description = "Zookeeper instance count"
  type        = number
}

variable "solr_instance_type" {
  description = "Solr instance type"
  type        = string
}

variable "solr_instance_count" {
  description = "Solr instance count"
  type        = number
}

variable "efs_solrs_mount" {
  description = "The EFS solrs cluster backup mount point"
  type        = string
}

variable "efs_zookeepers_mount" {
  description = "The EFS zookeepers cluster backup mount point"
  type        = string
}

variable "postgresql_password" {
  description = "Database postgresql password"
  type        = string
}

variable "postgresql_admin_password" {
  description = "Database postgresql admin password"
  type        = string
}

# rds
variable "rds_instance_type" {
  description = "Database instance type"
  type        = string
}

variable "rds_storage_size" {
  description = "Database instance size"
  type        = number
}

variable "rds_kms_key_id" {
  description = "Database encryption kms key_id"
  type        = string
}

variable "rds_master_user" {
  description = "Database postgres master user"
  type        = string
}

variable "rds_master_password" {
  description = "RDR database postgres master password"
  type        = string
}

variable "engine_version" {
  description = "RDR database postgres engine version"
  type        = string
}

variable "family" {
  description = "RDR database postgres family"
  type        = string
}

variable "postgresql_user" {
  description = "Database dataverse postgres user"
  type        = string
}

variable "postgresql_database" {
  description = "Database dataverse postgresql database"
  type        = string
}

# app
variable "app_instance_type" {
  description = "Application instance type"
  type        = string
}
