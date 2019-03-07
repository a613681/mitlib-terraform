resource "aws_route53_record" "oatf" {
  name    = "open-access"
  ttl     = 300
  type    = "CNAME"
  zone_id = "${module.shared.public_zoneid}"
  records = ["live-mitlib-openaccess.pantheonsite.io"]
}

resource "aws_route53_record" "oatf_dev" {
  name    = "open-access-dev"
  ttl     = 300
  type    = "CNAME"
  zone_id = "${module.shared.public_zoneid}"
  records = ["dev-mitlib-openaccess.pantheonsite.io"]
}

resource "aws_route53_record" "oatf_test" {
  name    = "open-access-test"
  ttl     = 300
  type    = "CNAME"
  zone_id = "${module.shared.public_zoneid}"
  records = ["test-mitlib-openaccess.pantheonsite.io"]
}
