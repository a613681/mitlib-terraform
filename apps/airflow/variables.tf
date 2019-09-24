variable "postgres_username" {
  type        = string
  description = "PostgreSQL username"
  default     = "postgres"
}

variable "postgres_password" {
  type        = string
  description = "PostgreSQL password"
}

variable "postgres_instance_type" {
  type        = string
  description = "PostgreSQL instance type"
  default     = "db.t3.micro"
}

variable "airflow_fernet_key" {
  type        = string
  description = "Fernet key for encrypting Airflow connections"
}
