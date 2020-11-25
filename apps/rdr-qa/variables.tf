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


variable "app_instance_type" {
  description = "Application instance type"
  type        = string
}
