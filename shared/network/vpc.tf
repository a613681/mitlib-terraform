# We don't use our tf-mod-name module for VPC
#It overrides a better naming schema provided by this module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.50.0"

  name = "${var.name}"
  cidr = "${var.cidr}"

  azs             = "${var.azs}"
  private_subnets = "${var.private_subnets}"
  public_subnets  = "${var.public_subnets}"

  enable_nat_gateway   = "true"
  enable_vpn_gateway   = "false"
  enable_dhcp_options  = "true"
  enable_dns_hostnames = "true"
  enable_s3_endpoint   = "true"

  #dhcp_options_domain_name = "mitlib.net"
  #dhcp_options_ntp_servers = ["169.254.169.123"]
  tags {
    appname     = "vpc"
    terraform   = "true"
    environment = "${terraform.workspace}"
  }
}
