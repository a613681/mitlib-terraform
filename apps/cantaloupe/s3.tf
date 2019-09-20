# Create S3 Bucket for storing images and create IAM user
module "s3store" {
  source = "github.com/mitlibraries/tf-mod-s3-iam?ref=0.11"
  name   = "cantaloupe-storage"
}

resource "aws_iam_user_policy_attachment" "store_ro" {
  user       = "${aws_iam_user.s3store.name}"
  policy_arn = "${module.s3store.readonly_arn}"
}

resource "aws_iam_user" "s3store" {
  name          = "${module.label.name}-app-ro"
  path          = "/"
  force_destroy = "false"
  tags          = "${module.label.tags}"
}

resource "aws_iam_access_key" "s3store" {
  user = "${aws_iam_user.s3store.name}"
}

# Create S3 Bucket for storing images and create IAM user
module "s3cache" {
  source             = "github.com/mitlibraries/tf-mod-s3-iam?ref=0.11"
  name               = "cantaloupe-cache"
  versioning_enabled = "false"

  #add in lifecycle rules for removing cached images once decided
}

resource "aws_iam_user_policy_attachment" "cache_rw" {
  user       = "${aws_iam_user.s3cache.name}"
  policy_arn = "${module.s3cache.readwrite_arn}"
}

resource "aws_iam_user" "s3cache" {
  name          = "${module.label.name}-app-rw"
  path          = "/"
  force_destroy = "false"
  tags          = "${module.label.tags}"
}

resource "aws_iam_access_key" "s3cache" {
  user = "${aws_iam_user.s3cache.name}"
}
