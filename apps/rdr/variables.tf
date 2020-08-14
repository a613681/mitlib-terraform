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

variable "app_instance_type" {
  description = "App instance type"
  type        = string
}

variable "db_instance_type" {
  description = "Database instance type"
  type        = string
}

variable "db_storage_size" {
  description = "Database instance size"
  type        = number
}
