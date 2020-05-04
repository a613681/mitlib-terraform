
variable "region" {
  default = "us-east-1"
}

variable "vpc_id" {
  type        = string
  description = "VPC to build infrastructure in"
}

variable "ec2_subnet" {
  type        = string
  description = "Subnet to use for ec2 host"
}

variable "ingress_cidr_blocks" {
  type    = list(string)
  default = []
}

variable "ssh_port" {
  description = "ssh access"
  type        = number
  default     = "22"
}

variable "ami" {
  type        = string
  description = "Instance ami"
  default     = ""
}

variable "instance_type" {
  description = "Instance Type (size)"
  default     = ""
}

variable "key_name" {
  description = "Launch configuration key name to be applied to created instance(s)"
  default     = ""
}

variable "volume_size" {
  description = "volume_size"
  type        = number
}

variable "volume_type" {
  type = string
}

variable "user_data_file" {
  description = "Custom user created bash script to run on creation"
  default     = ""
}

variable "get_pubkey_policy_file" {
  description = "Custom user created bash script to run on creation"
  default     = ""
}

variable "get_pubkey_assume_role_policy_file" {
  description = "Custom user created bash script to run on creation"
  default     = ""
}

variable "additional_user_data_script" {
  description = "Additional user-data script to run at the end"
  default     = ""
}

variable "ssh_user" {
  description = "SSH user created to access EC2 instance"
  default     = ""
}

variable "s3_bucket_pubkeys" {
  description = "S3 bucket containing public SSH keys"
  default     = ""
}

variable "s3_bucket_uri" {
  description = "URI of pre-created S3 bucket"
  default     = ""
}

variable "private_key_path" {
  description = "Path to the private SSH key, used to access the instance."
  default     = ""
}

variable "records" {
  type        = string
  default     = ""
  description = "DNS record to be created"
}

variable "provision_log" {
  default = ""
}

variable "playbooks" {
  default = ""
}

variable "dns_zone_id" {
  type        = string
  default     = ""
  description = "The ID of the DNS Zone in Route53"
}
