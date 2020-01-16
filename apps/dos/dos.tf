module "label" {
  source = "github.com/mitlibraries/tf-mod-name?ref=0.12"
  name   = "dos"
}

# A minimally configured S3 bucket. Lifecycle, encryption, web access, and
# replication configuration should be considered as the project progresses
resource "aws_s3_bucket" "default" {
  bucket = module.label.name
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = module.label.tags
}

# Definition for a basic admin level access policy
data "aws_iam_policy_document" "admin" {
  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:GetObject", "s3:ListBucket", "s3:DeleteObject"]
    resources = [aws_s3_bucket.default.arn, "${aws_s3_bucket.default.arn}/*"]
    effect    = "Allow"
  }

  # This is needed for users to be able to select the bucket
  statement {
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
    effect    = "Allow"
  }
}

# Create an IAM policy with the basic admin level access document
resource "aws_iam_policy" "admin" {
  name        = "${module.label.name}-admin"
  description = "Policy to allow IAM user full access to ${module.label.name} S3 bucket"
  policy      = "${data.aws_iam_policy_document.admin.json}"
}

# Attach a basic IAM admin policy that allows uploading and deleting objects
# to the IAM users specified in the by the "users" variable
resource "aws_iam_user_policy_attachment" "admin" {
  count      = length(var.users)
  user       = "${var.users[count.index]}"
  policy_arn = "${aws_iam_policy.admin.arn}"
}
