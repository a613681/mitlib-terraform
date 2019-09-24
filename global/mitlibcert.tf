module "acm_request_certificate" {
  source                            = "github.com/mitlibraries/tf-mod-acm-cert?ref=0.12"
  domain_name                       = "mitlib.net"
  ttl                               = "300"
  subject_alternative_names         = ["*.mitlib.net"]
  process_domain_validation_options = "true"
  validation_method                 = "DNS"

  tags = {
    terraform = "true"
    stage     = terraform.workspace
  }
}

