module "acm_request_certificate" {
  source                            = "git::https://github.com/mitlibraries/tf-mod-acm-cert?ref=master"
  domain_name                       = "mitlib.net"
  ttl                               = "300"
  subject_alternative_names         = ["*.mitlib.net"]
  process_domain_validation_options = "true"
  validation_method                 = "DNS"

  tags {
    terraform = "true"
    stage     = "${terraform.workspace}"
  }
}
