# A subset list of IAM accounts from the "users" list to give membership in
# the administrators group
variable "admins" {
  description = "A list of IAM accounts to add to the administrators group"
  type        = list
  default     = []
}

# A list of IAM accounts to create (usernames) including accounts to be
# added to the administrators group
variable "users" {
  description = "A list of IAM accounts to create (usernames)"
  type        = list
  default     = []
}
