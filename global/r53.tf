#Create the Public mitlib.net Zone
resource "aws_route53_zone" "main_pub" {
  name    = "mitlib.net"
  comment = "Public DNS Zone"
}

module "prodvpc" {
  source    = "git::https://github.com/mitlibraries/tf-mod-shared-provider?ref=master"
  workspace = "prod"
}

#Create the Private mitlib.net Zone and associate Prod VPC
resource "aws_route53_zone" "main_priv" {
  name    = "mitlib.net"
  comment = "Internal DNS"

  vpc {
    vpc_id = "${module.prodvpc.vpc_id}"
  }

  lifecycle {
    ignore_changes = ["vpc"]
  }
}

#Associate Stage VPC with Internal DNS
module "stagevpc" {
  source    = "git::https://github.com/mitlibraries/tf-mod-shared-provider?ref=master"
  workspace = "stage"
}

resource "aws_route53_zone_association" "stage" {
  zone_id = "${aws_route53_zone.main_priv.zone_id}"
  vpc_id  = "${module.stagevpc.vpc_id}"
}

# Add hosted zone and DNS entry for simile-widgets.org
resource "aws_route53_zone" "simile" {
  name = "simile-widgets.org"

  tags = {
    terraform   = "true"
    environment = "global"
    Name        = "simile-widgets.org"
  }
}

resource "aws_route53_record" "simile-ns" {
  zone_id = "${aws_route53_zone.simile.zone_id}"
  name    = "${aws_route53_zone.simile.name}"
  type    = "NS"
  ttl     = "86400"

  records = [
    "${aws_route53_zone.simile.name_servers.0}",
    "${aws_route53_zone.simile.name_servers.1}",
    "${aws_route53_zone.simile.name_servers.2}",
    "${aws_route53_zone.simile.name_servers.3}",
  ]
}

resource "aws_route53_record" "simile-soa" {
  zone_id = "${aws_route53_zone.simile.id}"
  name    = "${aws_route53_zone.simile.name}"
  type    = "SOA"
  ttl     = "900"

  records = [
    "${aws_route53_zone.simile.name_servers.0}. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400",
  ]
}

resource "aws_route53_record" "simile-web" {
  zone_id = "${aws_route53_zone.simile.id}"
  name    = "${aws_route53_zone.simile.name}"
  type    = "A"
  ttl     = "300"
  records = ["18.23.238.206"]
}

resource "aws_route53_record" "simile-trunk" {
  zone_id = "${aws_route53_zone.simile.id}"
  name    = "trunk.${aws_route53_zone.simile.name}"
  type    = "A"
  ttl     = "300"
  records = ["18.23.238.206"]
}

resource "aws_route53_record" "simile-service" {
  zone_id = "${aws_route53_zone.simile.id}"
  name    = "service.${aws_route53_zone.simile.name}"
  type    = "A"
  ttl     = "300"
  records = ["18.23.238.65"]
}

resource "aws_route53_record" "simile-api" {
  zone_id = "${aws_route53_zone.simile.id}"
  name    = "api.${aws_route53_zone.simile.name}"
  type    = "A"
  ttl     = "300"
  records = ["18.23.238.99"]
}

# Add hosted zone and DNS entry for dpworkshop.org
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

resource "aws_route53_record" "dpworkshop-web" {
  zone_id = "${aws_route53_zone.dpworkshop.id}"
  name    = "${aws_route53_zone.dpworkshop.name}"
  type    = "A"
  ttl     = "300"
  records = ["18.9.49.70"]
}
