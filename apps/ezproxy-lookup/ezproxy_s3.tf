module "label" {
  source = "git::https://github.com/mitlibraries/tf-mod-name?ref=master"
  name   = "ezproxy-lookup"
}

# Create AWS ezproxy-lookup app user to access S3 Bucket
resource "aws_iam_user" "default" {
  name          = "${module.label.name}-app-ro"
  path          = "/"
  force_destroy = "false"
}

module "ezproxy-lookup" {
  source             = "git::https://github.com/mitlibraries/tf-mod-s3-iam?ref=master"
  name               = "ezproxy-lookup"
  versioning_enabled = "true"
}

resource "aws_iam_user_policy_attachment" "default_ro" {
  user       = "${aws_iam_user.default.name}"
  policy_arn = "${module.ezproxy-lookup.readonly_arn}"
}

# Generate API credentials
resource "aws_iam_access_key" "default" {
  user = "${aws_iam_user.default.name}"
}

# Create a role with admin access for managing ezproxy lookup S3 bucket
# Access is maintained via "aws-672626379771-ezproxy-lookup" Moira list
resource "aws_iam_role" "ezproxy-lookup" {
  name        = "IdP-ezproxy-lookup"
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
  role       = "${aws_iam_role.ezproxy-lookup.name}"
  policy_arn = "${module.ezproxy-lookup.admin_arn}"
}
