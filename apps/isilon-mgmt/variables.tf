# Global variables
variable "region" {
  default = "us-east-1"
}

# EC2 Variables
variable "ec2_ami" {
  type        = string
  description = "The AMI to use for the EC2 instance"
  default     = ""
}

variable "ec2_inst_type" {
  description = "The instance type for the EC2 instance"
  default     = ""
}

variable "ec2_key_name" {
  description = "SSH key to assign to the EC2 instance"
  default     = ""
}

variable "ec2_subnet" {
  type        = string
  description = "The VPC subnet to use for ec2 host"
}

variable "ec2_vol_size" {
  description = "volume_size"
  type        = number
  default     = "8"
}

variable "ec2_vol_type" {
  description = "volume type"

}

variable "eip" {
  description = "Elastic IP address of the server"
  default     = ""
}

# VPC Variables
variable "vpc_id" {
  type        = string
  description = "The EC2 VPC to build infrastructure in"
}

# Security Group variables
variable "sec_access_subnets" {
  description = "Subnets to allow SSH access"
  type        = list(string)
  default     = []
}
