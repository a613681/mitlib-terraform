module "elasticsearch" {
  source = "git::https://github.com/mitlibraries/tf-mod-aws-elasticsearch?ref=master"
  name   = "elasticsearch"

  instance_count    = "${var.instance_count}"
  instance_type     = "${var.instance_type}"
  es_zone_awareness = "${var.es_zone_awareness}"
  ebs_volume_size   = "${var.ebs_volume_size}"
  es_version        = "${var.es_version}"
  encrypt_at_rest   = "false"

  advanced_options {
    "rest.action.multi.allow_explicit_index" = "true"
  }
}

##################################################################
# Create ES policy doc to allow write access from NAT Public IPs #
# Re-evaluate this when adding indices from other applications   #
##################################################################
data "aws_iam_policy_document" "default" {
  statement {
    actions = ["es:*"]

    resources = [
      "${module.elasticsearch.arn}",
      "${module.elasticsearch.arn}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"

      values = ["${module.shared.nat_public_ips}"]
    }
  }
}

resource "aws_elasticsearch_domain_policy" "default" {
  domain_name     = "${module.elasticsearch.domain_name}"
  access_policies = "${data.aws_iam_policy_document.default.json}"
}
