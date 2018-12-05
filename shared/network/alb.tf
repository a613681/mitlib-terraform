#Creates default restricted (18.0.0.0/9) ALB that uses *.mitlib.net cert by default

module "alb_restricted" {
  source                    = "git::https://github.com/mitlibraries/tf-mod-alb?ref=master"
  name                      = "alb-restricted"
  http_ingress_cidr_blocks  = ["${var.alb_cidrs}"]
  https_ingress_cidr_blocks = ["${var.alb_cidrs}"]
  vpc_id                    = "${module.vpc.vpc_id}"
  ip_address_type           = "ipv4"
  subnet_ids                = ["${module.vpc.public_subnets}"]
  access_logs_enabled       = "false"
  access_logs_region        = "${var.aws_region}"
  https_enabled             = "true"
  certificate_arn           = "${module.shared.mitlib_cert}"
}
