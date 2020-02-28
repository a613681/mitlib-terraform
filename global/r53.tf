#Create the Public mitlib.net Zone
resource "aws_route53_zone" "main_pub" {
  name    = "mitlib.net"
  comment = "Public DNS Zone"
}

module "prodvpc" {
  source    = "github.com/mitlibraries/tf-mod-shared-provider?ref=0.12"
  workspace = "prod"
}

#Create the Private mitlib.net Zone and associate Prod VPC
resource "aws_route53_zone" "main_priv" {
  name    = "mitlib.net"
  comment = "Internal DNS"

  vpc {
    vpc_id = module.prodvpc.vpc_id
  }

  lifecycle {
    ignore_changes = [vpc]
  }
}

#Associate Stage VPC with Internal DNS
module "stagevpc" {
  source    = "github.com/mitlibraries/tf-mod-shared-provider?ref=0.12"
  workspace = "stage"
}

resource "aws_route53_zone_association" "stage" {
  zone_id = aws_route53_zone.main_priv.zone_id
  vpc_id  = module.stagevpc.vpc_id
}
