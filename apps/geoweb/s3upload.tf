module "geoweb_upload" {
  source             = "git::https://github.com/mitlibraries/tf-mod-s3-iam?ref=master"
  name               = "geoweb-upload"
  versioning_enabled = "true"
}

module "geoweb_label" {
  source = "git::https://github.com/mitlibraries/tf-mod-name?ref=master"
  name   = "geoweb-upload"
}

# Create a role with admin access to S3 bucket for managing Geoweb Data Uploads
# Access is maintained via "aws-672626379771-geoweb-upload-stage" and
# "aws-672626379771-geoweb-upload-prod" Moira lists
resource "aws_iam_role" "geoweb_upload" {
  name        = "IdP-${module.geoweb_label.name}"
  description = "Moira list role for users to upload ${module.geoweb_label.name} S3 bucket"

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

resource "aws_iam_role_policy_attachment" "geoweb_upload" {
  role       = "${aws_iam_role.geoweb_upload.name}"
  policy_arn = "${module.geoweb_upload.admin_arn}"
}
