module "website" {
  source             = "github.com/mitlibraries/tf-mod-s3-website?ref=0.12"
  name               = "libstaff-archive"
  hostname           = "libstaff-archive.mitlib.net"
  parent_zone_id     = module.shared.public_zoneid
  force_destroy      = false
  versioning_enabled = false
}

data "aws_iam_policy_document" "default" {
  statement {
    actions = ["s3:GetObject"]

    resources = ["${module.website.s3_bucket_arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"

      values = var.sec_web_access_subnets
    }
  }
}

resource "aws_s3_bucket_policy" "default" {
  bucket = module.website.s3_bucket_name
  policy = data.aws_iam_policy_document.default.json
}
