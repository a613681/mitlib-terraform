variable "users" {
  description = "A list of IAM usernames that should have access to the bucket"
  type        = list(string)
  default     = []
}

variable "postgres_instance_type" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.micro"
}

variable "postgres_storage_size" {
  description = "Size of RDS database in GB"
  type        = number
}

variable "postgres_username" {
  description = "Database user"
  type        = string
  default     = "postgres"
}

variable "postgres_password" {
  description = "Database password"
  type        = string
}

variable "fargate_cpu" {
  description = "CPU value for DOS container"
  type        = number
  default     = 1024
}

variable "fargate_mem" {
  description = "Memory value for DOS container"
  type        = number
  default     = 2048
}
