resource "aws_route53_record" "oatf" {
  name    = "open-access"
  ttl     = 300
  type    = "A"
  zone_id = "${module.shared.public_zoneid}"
  records = ["18.9.49.139"]
}

resource "aws_route53_record" "oatf_dev" {
  name    = "open-access-dev"
  ttl     = 300
  type    = "CNAME"
  zone_id = "${module.shared.public_zoneid}"
  records = ["dev-mitlib-oatf.pantheonsite.io"]
}

resource "aws_route53_record" "oatf_test" {
  name    = "open-access-test"
  ttl     = 300
  type    = "A"
  zone_id = "${module.shared.public_zoneid}"
  records = ["18.9.49.142"]
}
