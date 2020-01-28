provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

#Tell terraform to use the S3 bucket and DynamoDB we created
terraform {
  required_version = ">= 0.12"

  backend "s3" {
    region         = "us-east-1"
    bucket         = "mit-tfstates-state"
    key            = "apps/dos.tfstate"
    dynamodb_table = "mit-tfstates-state-lock"
    encrypt        = true
  }
}

module "shared" {
  source = "github.com/mitlibraries/tf-mod-shared-provider?ref=0.12"
}

locals {
  env = terraform.workspace

  shared_alb_dns = {
    stage = module.shared.alb_restricted_dnsname
    prod  = module.shared.alb_restricted_dnsname
  }

  shared_alb_listeners = {
    stage = module.shared.alb_restricted_https_listener_arn
    prod  = module.shared.alb_restricted_https_listener_arn
  }

  shared_alb_sgids = {
    stage = module.shared.alb_restricted_sgid
    prod  = module.shared.alb_restricted_sgid
  }
}
