#######################
### Restricted ALB ###
######################
#Creates default restricted (18.0.0.0/9) ALB that uses *.mitlib.net cert by default
module "mitnet_alb_restricted" {
  source                    = "github.com/mitlibraries/tf-mod-alb?ref=0.12"
  name                      = "mitnet-alb-restricted"
  http_ingress_cidr_blocks  = var.alb_cidrs
  https_ingress_cidr_blocks = var.alb_cidrs
  vpc_id                    = var.vpc_id
  ip_address_type           = "ipv4"
  subnet_ids                = var.public_subnets
  access_logs_enabled       = "false"
  access_logs_region        = var.aws_region
  https_enabled             = "true"
  certificate_arn           = module.shared.mitlib_cert
}

module "mitnet_sg_label" {
  source = "github.com/mitlibraries/tf-mod-name?ref=0.12"
  name   = "mitnet-alb-restricted"
}

# Create default security group to allow all ingress from restricted ALB
module "mitnet_all_access_from_alb" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.8.0"

  name        = "${module.mitnet_alb_restricted.alb_name} all Ingress"
  description = "Allow all ingress from restricted ALB"
  vpc_id      = var.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      source_security_group_id = module.mitnet_alb_restricted.security_group_id
    },
  ]

  number_of_computed_ingress_with_source_security_group_id = 1
  tags                                                     = "${module.sg_label.tags}"
}

#########################
### Public Facing ALB ###
#########################
#Creates default public ALB that uses *.mitlib.net cert by default
module "mitnet_alb_public" {
  source              = "github.com/mitlibraries/tf-mod-alb?ref=0.12"
  name                = "mitnet-alb-public"
  vpc_id              = var.vpc_id
  ip_address_type     = "ipv4"
  subnet_ids          = var.public_subnets
  access_logs_enabled = "false"
  access_logs_region  = var.aws_region
  https_enabled       = "true"
  certificate_arn     = module.shared.mitlib_cert
}

module "mitnet_sg_label_public" {
  source = "github.com/mitlibraries/tf-mod-name?ref=0.12"
  name   = "mitnet-alb-public"
}

# Create default security group to allow all ingress from public ALB

module "all_access_from_mitnet_alb_public" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.8.0"

  name        = "${module.mitnet_alb_public.alb_name} all Ingress"
  description = "Allow all ingress from restricted ALB"
  vpc_id      = var.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      source_security_group_id = module.mitnet_alb_public.security_group_id
    },
  ]

  number_of_computed_ingress_with_source_security_group_id = 1
  tags                                                     = module.sg_label_public.tags
}


