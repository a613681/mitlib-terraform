# Route53 variables
variable "r53_archivesspace_cname_public_value" {
  description = "The archivesspace public CName DNS record value"
  type        = list(string)
}

variable "r53_archivesspace-staff_cname_public_value" {
  description = "The archivesspace-staff public CName DNS record value"
  type        = list(string)
}

variable "r53_emmas-lib_cname_public_value" {
  description = "The emmas-lib public CName DNS record value"
  type        = list(string)
}

variable "r53_emmastaff-lib_cname_public_value" {
  description = "The emmastaff-lib public CName DNS record value"
  type        = list(string)
}

variable "r53_archivesspace_cname_private_value" {
  description = "The archivesspace private CName DNS record value"
  type        = list(string)
}
