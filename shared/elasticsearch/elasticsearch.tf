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
