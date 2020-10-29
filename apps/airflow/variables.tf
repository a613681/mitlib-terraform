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

variable "rdr_key" {
  type        = string
  description = "Authentication key for RDR instance. The reason this is here and not in the RDR app is that the ingest process needs this set in the container environment."
}
