# The SSL certificate was created manually (via MIT) and imported manually
# We will investigate options for generating SSL certificates in the future
module "label" {
  source = "github.com/mitlibraries/tf-mod-name?ref=0.11"
  name   = "lib-digitalobjects"
}

module "lib-digitalobjects" {
  source = "github.com/mitlibraries/tf-mod-cdn-s3?ref=0.11"
  name   = "lib-digitalobjects"

  aliases = ["lib-digitalobjects-${terraform.workspace}.mitlib.net"]

  ext_aliases          = "${var.ext_aliases}"
  parent_zone_name     = "mitlib.net"
  cors_allowed_origins = "${var.ext_aliases}"

  custom_error_response = [
    {
      error_code         = "404"
      response_code      = "200"
      response_page_path = "/index.html"
    },
  ]

  acm_certificate_arn = "${var.acm_certificate_arn}"
}

# Create an admin user and give access to our bucket to manage objects
data "aws_iam_policy_document" "admin" {
  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:GetObject", "s3:ListBucket", "s3:DeleteObject"]
    resources = ["${module.lib-digitalobjects.s3_bucket_arn}", "${module.lib-digitalobjects.s3_bucket_arn}/*"]
    effect    = "Allow"
  }

  #This is needed for users to be able to select the bucket
  statement {
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "admin" {
  name        = "${module.label.name}-admin"
  description = "Policy to allow IAM user full access to ${module.label.name} S3 bucket"
  policy      = "${data.aws_iam_policy_document.admin.json}"
}

resource "aws_iam_user" "default" {
  name          = "${module.label.name}-admin"
  path          = "/"
  force_destroy = "false"
}

resource "aws_iam_user_policy_attachment" "admin" {
  user       = "${aws_iam_user.default.name}"
  policy_arn = "${aws_iam_policy.admin.arn}"
}

# Generate API credentials
resource "aws_iam_access_key" "default" {
  user = "${aws_iam_user.default.name}"
}
