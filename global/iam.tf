# Create IAM user accounts
resource "aws_iam_user" "users" {
  for_each = toset(var.users)
  name     = each.key

  # Do not delete the account if the user has created non-terraform managed
  # access keys that may be in use.
  force_destroy = false
}

resource "aws_iam_group" "admins" {
  name = "Administrators"
}

# Give the IAM accounts listed in the "admins" variable list membership in
# the adminstrators group.
resource "aws_iam_group_membership" "admins" {
  name = "Infrastructure Administrators"

  users = var.admins
  group = aws_iam_group.admins.name
}

resource "aws_iam_group_policy_attachment" "admins" {
  group      = aws_iam_group.admins.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
