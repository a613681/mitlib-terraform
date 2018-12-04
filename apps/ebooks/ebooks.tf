module "label" {
  source = "git::https://github.com/mitlibraries/tf-mod-name?ref=master"
  name   = "ebooks"
}

#create our AWS ebooks user
resource "aws_iam_user" "default" {
  name          = "${module.label.name}-readwrite"
  path          = "/"
  force_destroy = "false"
}

module "ebooks" {
  source             = "git::https://github.com/mitlibraries/tf-mod-s3-iam?ref=master"
  name               = "ebooks"
  versioning_enabled = "true"
}

resource "aws_iam_user_policy_attachment" "default_rw" {
  user       = "${aws_iam_user.default.name}"
  policy_arn = "${module.ebooks.readwrite_arn}"
}

# Generate API credentials
resource "aws_iam_access_key" "default" {
  user = "${aws_iam_user.default.name}"
}
