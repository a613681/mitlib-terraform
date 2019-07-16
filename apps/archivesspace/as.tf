resource "aws_route53_record" "as" {
  name    = "archivesspace"
  ttl     = 3600
  type    = "CNAME"
  zone_id = "${module.shared.public_zoneid}"
  records = ["as-prod-general-app4.LYRTECH.ORG"]
}

resource "aws_route53_record" "astaff" {
  name    = "archviesspace-staff"
  ttl     = 3600
  type    = "CNAME"
  zone_id = "${module.shared.public_zoneid}"
  records = ["as-prod-general-app4.LYRTECH.ORG"]
}

resource "aws_route53_record" "emma" {
  name    = "emmas-lib"
  ttl     = 600
  type    = "CNAME"
  zone_id = "${module.shared.public_zoneid}"
  records = ["as-prod-general-app4.LYRTECH.ORG"]
}

resource "aws_route53_record" "emmastaff" {
  name    = "emmastaff-lib"
  ttl     = 600
  type    = "CNAME"
  zone_id = "${module.shared.public_zoneid}"
  records = ["as-prod-general-app4.LYRTECH.ORG"]
}
