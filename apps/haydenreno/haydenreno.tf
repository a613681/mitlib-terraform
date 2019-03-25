resource "aws_route53_record" "haydenrenonews" {
  name    = "haydenrenonews"
  ttl     = 300
  type    = "CNAME"
  zone_id = "${module.shared.public_zoneid}"
  records = ["live-haydenrenovation.pantheonsite.io"]
}

resource "aws_route53_record" "haydenrenonews_dev" {
  name    = "haydenrenonews-dev"
  ttl     = 300
  type    = "CNAME"
  zone_id = "${module.shared.public_zoneid}"
  records = ["dev-haydenrenovation.pantheonsite.io"]
}

resource "aws_route53_record" "haydenrenonews_test" {
  name    = "haydenrenonews-test"
  ttl     = 300
  type    = "CNAME"
  zone_id = "${module.shared.public_zoneid}"
  records = ["test-haydenrenovation.pantheonsite.io"]
}
