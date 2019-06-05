variable postgres_username {
  type        = "string"
  description = "PostgreSQL RDS admin username"
}

variable postgres_password {
  type        = "string"
  description = "PostgreSQL RDS admin password"
}

variable postgres_database {
  type        = "string"
  description = "Name of PostGres database"
  default     = "postgis"
}

variable secret_key {
  type        = "string"
  description = "Rails secret key"
}

variable geoserver_username {
  type        = "string"
  description = "GeoServer username"
}

variable geoserver_password {
  type        = "string"
  description = "GeoServer password"
}
