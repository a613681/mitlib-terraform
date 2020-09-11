# Security variables

variable "sec_web_access_subnets" {
  description = "Subnets to allow access to the Libstaff website"
  type        = list(string)
}
