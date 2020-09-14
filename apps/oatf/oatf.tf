resource "aws_route53_record" "oatf" {
  name    = "open-access"
  ttl     = 300
  type    = "CNAME"
  zone_id = module.shared.public_zoneid
  records = var.r53_oatf_value
}

resource "aws_route53_record" "oatf_dev" {
  name    = "open-access-dev"
  ttl     = 300
  type    = "CNAME"
  zone_id = module.shared.public_zoneid
  records = var.r53_oatf_dev_value
}

resource "aws_route53_record" "oatf_test" {
  name    = "open-access-test"
  ttl     = 300
  type    = "CNAME"
  zone_id = module.shared.public_zoneid
  records = var.r53_oatf_test_value
}
