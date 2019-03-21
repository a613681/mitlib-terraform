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

output "mitlib_cert" {
  description = "*.mitlib.net wildcard certificate"
  value       = "${module.acm_request_certificate.arn}"
}

output "mit_saml_arn" {
  description = "MIT Identity provider arn (SAML Federated login)"
  value       = "${aws_iam_saml_provider.mit.arn}"
}

output "docsvcs_beanstalk_name" {
  description = "Name of Docsvcs Elastic Beanstalk application"
  value       = "${aws_elastic_beanstalk_application.docsvcs.name}"
}
