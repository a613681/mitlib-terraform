output "public_zoneid" {
  description = "Route53 Public Zone ID"
  value       = "${aws_route53_zone.main_pub.zone_id}"
}

output "public_zonename" {
  description = "Route53 Public Zone name"
  value       = "${aws_route53_zone.main_pub.name}"
}

output "private_zoneid" {
  description = "Route53 Private Zone ID"
  value       = "${aws_route53_zone.main_priv.zone_id}"
}

output "private_zonename" {
  description = "Route53 Private Zone name"
  value       = "${aws_route53_zone.main_priv.name}"
}
