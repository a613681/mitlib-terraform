resource "aws_route53_record" "tdr" {
  name    = "tdr"
  ttl     = 300
  type    = "CNAME"
  zone_id = "${module.shared.public_zoneid}"
  records = ["live-mitlib-trac.pantheonsite.io"]
}

resource "aws_route53_record" "tdr_dev" {
  name    = "tdr-dev"
  ttl     = 300
  type    = "CNAME"
  zone_id = "${module.shared.public_zoneid}"
  records = ["dev-mitlib-trac.pantheonsite.io"]
}

resource "aws_route53_record" "tdr_test" {
  name    = "tdr-test"
  ttl     = 300
  type    = "CNAME"
  zone_id = "${module.shared.public_zoneid}"
  records = ["test-mitlib-trac.pantheonsite.io"]
}
