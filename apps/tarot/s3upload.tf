module "tarot_upload" {
  source             = "git::https://github.com/mitlibraries/tf-mod-s3-iam?ref=master"
  name               = "tarot-upload"
  versioning_enabled = "true"
}

module "tarot_label" {
  source = "git::https://github.com/mitlibraries/tf-mod-name?ref=master"
  name   = "tarot-label"
}

# Create a role with admin access to S3 bucket for managing Tarot Data Uploads
# Access is maintained via "aws-672626379771-tarot" Moira list
resource "aws_iam_role" "tarot_upload" {
  name        = "IdP-tarot"
  description = "Moira list role for users to upload ${module.tarot_label.name} S3 bucket"

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

resource "aws_iam_role_policy_attachment" "tarot_upload" {
  role       = "${aws_iam_role.tarot_upload.name}"
  policy_arn = "${module.tarot_upload.admin_arn}"
}
