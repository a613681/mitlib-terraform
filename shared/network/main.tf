provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

#Tell terraform to use the S3 bucket and DynamoDB we created
terraform {
  backend "s3" {
    region         = "us-east-1"
    bucket         = "mit-tfstates-state"
    key            = "network/terraform.tfstate"
    dynamodb_table = "mit-tfstates-state-lock"
    encrypt        = true
  }
}

module "shared" {
  source = "github.com/mitlibraries/tf-mod-shared-provider?ref=0.12"
}

