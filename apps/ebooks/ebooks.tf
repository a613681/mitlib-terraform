module "label" {
  source = "github.com/mitlibraries/tf-mod-name?ref=0.12"
  name   = "ebooks"
}

# Create AWS ebooks app user to access S3 Bucket
resource "aws_iam_user" "default" {
  name          = "${module.label.name}-app-ro"
  path          = "/"
  force_destroy = "false"
}

module "ebooks" {
  source             = "github.com/mitlibraries/tf-mod-s3-iam?ref=0.12"
  name               = "ebooks"
  versioning_enabled = "true"
}

resource "aws_iam_user_policy_attachment" "default_ro" {
  user       = aws_iam_user.default.name
  policy_arn = module.ebooks.readonly_arn
}

# Generate API credentials
resource "aws_iam_access_key" "default" {
  user = aws_iam_user.default.name
}

# Create a role with admin access for managing ebooks in S3 bucket
# Access is maintained via "aws-672626379771-ebooks-admin" Moira list
resource "aws_iam_role" "cataloger" {
  name        = "IdP-ebooks-admin"
  description = "Moira list role for users to manage ${module.label.name} S3 bucket"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Federated": "${module.shared.mit_saml_arn}"
      },
      "Action": "sts:AssumeRoleWithSAML",
      "Condition": {
        "StringEquals": {
          "SAML:aud": "https://signin.aws.amazon.com/saml"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "admin" {
  role       = aws_iam_role.cataloger.name
  policy_arn = module.ebooks.admin_arn
}
