# Create IAM user accounts
resource "aws_iam_user" "users" {
  count = length(var.users)
  name  = element(var.users, count.index)

  # Do not delete the account if the user has created non-terraform managed
  # access keys that may be in use.
  force_destroy = false
}

# Give the IAM accounts listed in the "admins" variable list membership in
# the adminstrators group.
resource "aws_iam_group_membership" "admins" {
  name = "Infrastructure Administrators"

  users = var.admins
  group = "Administrators"
}
