#######################
### Restricted ALB ###
######################
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

module "sg_label" {
  source = "git::https://github.com/mitlibraries/tf-mod-name?ref=master"
  name   = "alb-restricted"
}

# Create default security group to allow all ingress from restricted ALB
module "all_access_from_alb" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "2.13.0"

  name        = "${module.alb_restricted.alb_name} all Ingress"
  description = "Allow all ingress from restricted ALB"
  vpc_id      = "${module.shared.vpc_id}"

  ingress_with_source_security_group_id = [
    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      source_security_group_id = "${module.alb_restricted.security_group_id}"
    },
  ]

  tags = "${module.sg_label.tags}"
}
