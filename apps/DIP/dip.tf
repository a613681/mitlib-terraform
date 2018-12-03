module "label" {
  source = "git::https://github.com/mitlibraries/tf-mod-name?ref=master"
  name   = "DIP-aleph-S3"
}

module "alephs3" {
  source             = "git::https://github.com/mitlibraries/tf-mod-s3-iam?ref=master"
  name               = "DIP-aleph-S3"
  access             = "readwrite"
  versioning_enabled = "true"
}

#create our AWS user to access the S3 Bucket
resource "aws_iam_user" "default" {
  name          = "${module.label.name}-${module.alephs3.access}"
  path          = "/"
  force_destroy = "false"
}

resource "aws_iam_user_policy_attachment" "default_rw" {
  user       = "${aws_iam_user.default.name}"
  policy_arn = "${module.alephs3.readwrite_arn[0]}"
}

# Generate API credentials
resource "aws_iam_access_key" "default" {
  user = "${aws_iam_user.default.name}"
}
