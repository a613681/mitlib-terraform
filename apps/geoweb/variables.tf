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

variable postgres_instance_type {
  type        = "string"
  description = "Instance type for Postgres database"
  default     = "db.t3.micro"
}

variable postgres_storage_size {
  type        = "string"
  description = "Allocated size of Postgres database"
  default     = "160"
}

variable secret_key {
  type        = "string"
  description = "Rails secret key"
}

variable instance_type {
  type        = "string"
  description = "EC2 instance type"
  default     = "t3.small"
}

variable geoserver_username {
  type        = "string"
  description = "GeoServer username"
}

variable geoserver_password {
  type        = "string"
  description = "GeoServer password"
}

variable geoblacklight_internal_domain {
  type        = "string"
  description = "A record domain name. This is the internal domain name."
}

variable geoblacklight_public_domain {
  type        = "string"
  description = "CNAME record domain name. This is the public facing domain name."
}

variable geoblacklight_cpu {
  type        = "string"
  description = "CPU setting for Geoblacklight Fargate task"
  default     = "512"
}

variable geoblacklight_memory {
  type        = "string"
  description = "Memory setting for Geoblacklight Fargate task"
  default     = "1024"
}

variable storage_bucket_name {
  type        = "string"
  description = "Name of storage bucket for layers"
}

variable rails_max_threads {
  type        = "string"
  description = "Maximum number of puma threads"
  default     = "5"
}

variable rails_auth_type {
  type        = "string"
  description = "Authentication type for Geoweb (developer or saml)"
  default     = "saml"
}

variable idp_metadata_url {
  type        = "string"
  description = "IDP_METADATA_URL envvar for SAML auth"
  default     = "https://touchstone.mit.edu/metadata/MIT-metadata.xml"
}

variable idp_entity_id {
  type        = "string"
  description = "IDP_ENTITY_ID envvar for SAML auth"
  default     = "https://idp.mit.edu/shibboleth"
}

variable idp_sso_url {
  type        = "string"
  description = "IDP_SSO_URL envvar for SAML auth"
  default     = "https://idp.mit.edu/idp/profile/SAML2/Redirect/SSO"
}

variable sp_entity_id {
  type        = "string"
  description = "SP_ENTITY_ID envvar for SAML auth"
}

variable urn_email {
  type        = "string"
  description = "URN_EMAIL envvar for SAML auth"
}

variable sp_certificate {
  type        = "string"
  description = "SP_CERTIFICATE envvar for SAML auth"
}

variable sp_private_key {
  type        = "string"
  description = "SP_PRIVATE_KEY envvar for SAML auth"
}
