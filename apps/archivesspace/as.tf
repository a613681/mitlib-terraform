resource "aws_route53_record" "as" {
  name    = "archivesspace"
  ttl     = 3600
  type    = "CNAME"
  zone_id = module.shared.public_zoneid
  records = var.r53_archivesspace_cname_public_value
}

resource "aws_route53_record" "astaff" {
  name    = "archivesspace-staff"
  ttl     = 3600
  type    = "CNAME"
  zone_id = module.shared.public_zoneid
  records = var.r53_archivesspace-staff_cname_public_value
}

resource "aws_route53_record" "emma" {
  name    = "emmas-lib"
  ttl     = 600
  type    = "CNAME"
  zone_id = module.shared.public_zoneid
  records = var.r53_emmas-lib_cname_public_value
}

resource "aws_route53_record" "emmastaff" {
  name    = "emmastaff-lib"
  ttl     = 600
  type    = "CNAME"
  zone_id = module.shared.public_zoneid
  records = var.r53_emmastaff-lib_cname_public_value
}

resource "aws_route53_record" "as_private" {
  name    = "archivesspace"
  ttl     = 3600
  type    = "CNAME"
  zone_id = module.shared.private_zoneid
  records = var.r53_archivesspace_cname_private_value
}
