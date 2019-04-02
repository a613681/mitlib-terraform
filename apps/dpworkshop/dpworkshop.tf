# Create dpworkshop.org hosted zone and associated DNS entries

resource "aws_route53_zone" "dpworkshop" {
  name = "dpworkshop.org"

  tags = {
    terraform   = "true"
    environment = "global"
    Name        = "dpworkshop.org"
  }
}

resource "aws_route53_record" "dpworkshop-ns" {
  zone_id = "${aws_route53_zone.dpworkshop.zone_id}"
  name    = "${aws_route53_zone.dpworkshop.name}"
  type    = "NS"
  ttl     = "86400"

  records = [
    "${aws_route53_zone.dpworkshop.name_servers.0}",
    "${aws_route53_zone.dpworkshop.name_servers.1}",
    "${aws_route53_zone.dpworkshop.name_servers.2}",
    "${aws_route53_zone.dpworkshop.name_servers.3}",
  ]
}

resource "aws_route53_record" "dpworkshop-soa" {
  zone_id = "${aws_route53_zone.dpworkshop.id}"
  name    = "${aws_route53_zone.dpworkshop.name}"
  type    = "SOA"
  ttl     = "900"

  records = [
    "${aws_route53_zone.dpworkshop.name_servers.0}. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400",
  ]
}

# Create dpworkshop.org DNS entries
resource "aws_route53_record" "dpworkshop-web" {
  zone_id = "${aws_route53_zone.dpworkshop.id}"
  name    = "${aws_route53_zone.dpworkshop.name}"
  type    = "A"
  ttl     = "300"
  records = ["23.185.0.3"]
}

resource "aws_route53_record" "dpworkshop-web1" {
  zone_id = "${aws_route53_zone.dpworkshop.id}"
  name    = "${aws_route53_zone.dpworkshop.name}"
  type    = "AAAA"
  ttl     = "300"
  records = ["2620:12a:8000::3", "2620:12a:8001::3"]
}

resource "aws_route53_record" "dpworkshop_dev" {
  name    = "dev"
  ttl     = 300
  type    = "CNAME"
  zone_id = "${aws_route53_zone.dpworkshop.id}"
  records = ["dev-mitlib-dpworkshop.pantheonsite.io"]
}

resource "aws_route53_record" "dpworkshop_test" {
  name    = "test"
  ttl     = 300
  type    = "CNAME"
  zone_id = "${aws_route53_zone.dpworkshop.id}"
  records = ["test-mitlib-dpworkshop.pantheonsite.io"]
}

# Create TDR Demo DNS entries
resource "aws_route53_record" "tdr" {
  name    = "tdr"
  ttl     = 300
  type    = "CNAME"
  zone_id = "${aws_route53_zone.dpworkshop.id}"
  records = ["live-mitlib-trac-demo.pantheonsite.io"]
}

resource "aws_route53_record" "tdr_dev" {
  name    = "tdr-dev"
  ttl     = 300
  type    = "CNAME"
  zone_id = "${aws_route53_zone.dpworkshop.id}"
  records = ["dev-mitlib-trac-demo.pantheonsite.io"]
}

resource "aws_route53_record" "tdr_test" {
  name    = "tdr-test"
  ttl     = 300
  type    = "CNAME"
  zone_id = "${aws_route53_zone.dpworkshop.id}"
  records = ["test-mitlib-trac-demo.pantheonsite.io"]
}
