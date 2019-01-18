module "label" {
  source = "git::https://github.com/mitlibraries/tf-mod-name?ref=master"
  name   = "DIP-aleph-S3"
}

module "alephs3" {
  source             = "git::https://github.com/mitlibraries/tf-mod-s3-iam?ref=master"
  name               = "DIP-aleph-S3"
  versioning_enabled = "true"
}

# Create our AWS user to access the S3 Bucket
resource "aws_iam_user" "default" {
  name          = "${module.label.name}-readwrite"
  path          = "/"
  force_destroy = "false"
}

resource "aws_iam_user_policy_attachment" "default_rw" {
  user       = "${aws_iam_user.default.name}"
  policy_arn = "${module.alephs3.readwrite_arn}"
}

# Generate API credentials
resource "aws_iam_access_key" "default" {
  user = "${aws_iam_user.default.name}"
}

# Create policcies to access the elasticsearch instance
data "aws_iam_policy_document" "read" {
  statement {
    actions = ["es:ESHttpGet"]

    resources = [
      "${module.shared.es_arn}/aleph*",
    ]
  }
}

data "aws_iam_policy_document" "write" {
  statement {
    actions = ["es:ESHttp*"]

    resources = [
      "${module.shared.es_arn}/aleph*",
    ]
  }
}

resource "aws_iam_policy" "es_read" {
  name        = "dip-esindexes-read"
  description = "Policy to allow IAM user read only access to DIP ES indexes"
  policy      = "${data.aws_iam_policy_document.read.json}"
}

resource "aws_iam_policy" "es_write" {
  name        = "dip-esindexes-write"
  description = "Policy to allow IAM user write access to DIP ES indexes"
  policy      = "${data.aws_iam_policy_document.write.json}"
}
