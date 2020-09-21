resource "aws_route53_record" "haydenrenonews" {
  name    = "haydenrenonews"
  ttl     = 300
  type    = "CNAME"
  zone_id = module.shared.public_zoneid
  records = var.r53_haydenrenonews_value
}

resource "aws_route53_record" "haydenrenonews_dev" {
  name    = "haydenrenonews-dev"
  ttl     = 300
  type    = "CNAME"
  zone_id = module.shared.public_zoneid
  records = var.r53_haydenrenonews_dev_value
}

resource "aws_route53_record" "haydenrenonews_test" {
  name    = "haydenrenonews-test"
  ttl     = 300
  type    = "CNAME"
  zone_id = module.shared.public_zoneid
  records = var.r53_haydenrenonews_test_value
}
