module "website" {
  source         = "git::https://github.com/mitlibraries/tf-mod-s3-website?ref=master"
  name           = "libstaff-archive"
  hostname       = "libstaff-archive.mitlib.net"
  parent_zone_id = "${module.shared.public_zoneid}"
}

resource "aws_s3_bucket_policy" "default" {
  bucket = "${module.website.s3_bucket_name}"
  policy = "${data.aws_iam_policy_document.default.json}"
}

data "aws_iam_policy_document" "default" {
  statement = [{
    actions = ["s3:GetObject"]

    resources = ["${module.website.s3_bucket_arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"

      values = ["18.28.0.0/16", "18.30.0.0/16"]
    }
  }]
}
