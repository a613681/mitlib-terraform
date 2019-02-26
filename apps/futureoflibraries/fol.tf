resource "aws_route53_record" "fol" {
  name    = "future-of-libraries"
  ttl     = 300
  type    = "A"
  zone_id = "${module.shared.public_zoneid}"
  records = ["18.9.49.56"]
}

resource "aws_route53_record" "fol_dev" {
  name    = "future-of-libraries-dev"
  ttl     = 300
  type    = "CNAME"
  zone_id = "${module.shared.public_zoneid}"
  records = ["dev-mitlib-futureoflibraries.pantheonsite.io"]
}

resource "aws_route53_record" "fol_test" {
  name    = "future-of-libraries-test"
  ttl     = 300
  type    = "A"
  zone_id = "${module.shared.public_zoneid}"
  records = ["18.9.49.57"]
}
