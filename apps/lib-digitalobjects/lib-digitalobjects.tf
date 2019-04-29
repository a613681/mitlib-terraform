# The SSL certificate was created manually (via MIT) and imported manually
# We will investigate options for generating SSL certificates in the future

module "lib-digitalobjects" {
  source = "git::https://github.com/mitlibraries/tf-mod-cdn-s3?ref=master"
  name   = "lib-digitalobjects"

  aliases = ["lib-digitalobjects-${terraform.workspace}.mitlib.net"]

  ext_aliases          = "${var.ext_aliases}"
  parent_zone_name     = "mitlib.net"
  cors_allowed_origins = "${var.ext_aliases}"

  custom_error_response = [
    {
      error_code         = "404"
      response_code      = "200"
      response_page_path = "/index.html"
    },
  ]

  acm_certificate_arn = "${var.acm_certificate_arn}"
}
