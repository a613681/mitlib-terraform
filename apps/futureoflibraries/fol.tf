resource "aws_route53_record" "fol" {
  name    = "future-of-libraries"
  ttl     = 300
  type    = "CNAME"
  zone_id = module.shared.public_zoneid
  records = var.r53_fol_value
}

resource "aws_route53_record" "fol_dev" {
  name    = "future-of-libraries-dev"
  ttl     = 300
  type    = "CNAME"
  zone_id = module.shared.public_zoneid
  records = var.r53_fol_dev_value
}

resource "aws_route53_record" "fol_test" {
  name    = "future-of-libraries-test"
  ttl     = 300
  type    = "CNAME"
  zone_id = module.shared.public_zoneid
  records = var.r53_fol_test_value
}
