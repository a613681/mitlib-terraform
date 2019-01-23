module "label" {
  source = "git::https://github.com/mitlibraries/tf-mod-name?ref=master"
  name   = "dip-aleph-S3"
}

module "alephs3" {
  source             = "git::https://github.com/mitlibraries/tf-mod-s3-iam?ref=master"
  name               = "dip-aleph-S3"
  versioning_enabled = "true"
}

# Create our AWS user to access the S3 Bucket
resource "aws_iam_user" "default" {
  name          = "${module.label.name}-readwrite"
  path          = "/"
  force_destroy = "false"
  tags          = "${module.label.tags}"
}

resource "aws_iam_user_policy_attachment" "default_rw" {
  user       = "${aws_iam_user.default.name}"
  policy_arn = "${module.alephs3.readwrite_arn}"
}

# Generate API credentials
resource "aws_iam_access_key" "default" {
  user = "${aws_iam_user.default.name}"
}

# Create more restricted read policy for timdex indices
data "aws_iam_policy_document" "read" {
  statement {
    actions = ["es:ESHttpGet"]

    resources = [
      "${module.shared.es_arn}/aleph*",
      "${module.shared.es_arn}/production*",
    ]
  }
}

module "es-label" {
  source = "git::https://github.com/mitlibraries/tf-mod-name?ref=master"
  name   = "dip-es-indexes"
}

resource "aws_iam_policy" "es_read" {
  name        = "${module.es-label.name}-read"
  description = "Policy to allow IAM user read only access to DIP ES indexes"
  policy      = "${data.aws_iam_policy_document.read.json}"
}

# Create API Credentials for Timdex (Heroku App) to read from Aleph index
module "timdex-es-label" {
  source = "git::https://github.com/mitlibraries/tf-mod-name?ref=master"
  name   = "timdex-es"
}

resource "aws_iam_user" "timdex" {
  name          = "${module.timdex-es-label.name}-read"
  path          = "/"
  force_destroy = "false"
  tags          = "${module.timdex-es-label.tags}"
}

resource "aws_iam_user_policy_attachment" "timdex_es_ro" {
  user       = "${aws_iam_user.timdex.name}"
  policy_arn = "${aws_iam_policy.es_read.arn}"
}

# Generate API credentials
resource "aws_iam_access_key" "timdex" {
  user = "${aws_iam_user.timdex.name}"
}
