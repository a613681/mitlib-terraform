provider "aws" {
  version = "~> 1.60.0 "
  region  = "us-east-1"
}

#Tell terraform to use the S3 bucket and DynamoDB we created
terraform {
  required_version = ">= 0.11.10"

  backend "s3" {
    region         = "us-east-1"
    bucket         = "mit-tfstates-state"
    key            = "apps/cantaloupe.tfstate"
    dynamodb_table = "mit-tfstates-state-lock"
    encrypt        = true
  }
}

#Get shared Resources
module "shared" {
  source = "git::https://github.com/mitlibraries/tf-mod-shared-provider?ref=master"
}
