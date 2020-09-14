resource "aws_route53_record" "tdr" {
  name    = "tdr"
  ttl     = 300
  type    = "CNAME"
  zone_id = module.shared.public_zoneid
  records = var.r53_trac_value
}

resource "aws_route53_record" "tdr_dev" {
  name    = "tdr-dev"
  ttl     = 300
  type    = "CNAME"
  zone_id = module.shared.public_zoneid
  records = var.r53_trac_dev_value
}

resource "aws_route53_record" "tdr_test" {
  name    = "tdr-test"
  ttl     = 300
  type    = "CNAME"
  zone_id = module.shared.public_zoneid
  records = var.r53_trac_test_value
}
