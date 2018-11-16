output "pub_zone" {
  value = "${aws_route53_zone.main_pub.zone_id}"
}

#output "priv_zone" {
#  value = "${aws_route53_zone.main_priv.zone_id}"
#}

