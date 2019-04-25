#The certificate was created manually (via MIT) and imported manually
#We will investigate options for generating SSL certificates in the future

module "iasc-diponline" {
  source  = "git::https://github.com/mitlibraries/tf-mod-cdn-s3?ref=master"
  name    = "iasc-diponline"
  aliases = ["iasc-diponline-${terraform.workspace}.mitlib.net"]

  #ext_aliases          = ["iasc-diponline.mit.edu"]
  parent_zone_name = "mitlib.net"

  #cors_allowed_origins = ["iasc-diponline.mit.edu"]

  custom_error_response = [
    {
      error_code         = "404"
      response_code      = "200"
      response_page_path = "/index.html"
    },
  ]
  acm_certificate_arn = "${module.shared.mitlib_cert}"

  #acm_certificate_arn = "arn:aws:acm:us-east-1:672626379771:certificate/cdb62536-c66f-4eff-940a-d90ecc869b0b"
}
