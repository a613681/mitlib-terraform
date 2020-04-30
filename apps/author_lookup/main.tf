/**
 * # Author Lookup API
 *
 * This module contains partial configuration for the Author Lookup API. The following items are created:
 *
 * * Lambda exection role
 * * Travis deploy user
 * * S3 bucket for Lambda
 * * Secret used by API
 *
 * The rest of the AWS resources are created/managed by zappa during deploy.
 **/
provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

terraform {
  backend "s3" {
    region         = "us-east-1"
    bucket         = "mit-tfstates-state"
    key            = "apps/author_lookup.tfstate"
    dynamodb_table = "mit-tfstates-state-lock"
    encrypt        = true
  }
}

module "shared" {
  source = "github.com/mitlibraries/tf-mod-shared-provider?ref=0.12"
}

