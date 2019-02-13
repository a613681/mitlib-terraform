/**
 * # Shared deploy resource
 *
 * This module provides a shared place for various deploy related resources. Currently, this just contains an S3 bucket that can be used for binaries needed during deploy.
 *
 **/
provider "aws" {
  version = "~> 1.56.0 "
  region  = "us-east-1"
}

#Tell terraform to use the S3 bucket and DynamoDB we created
terraform {
  required_version = ">= 0.11.10"

  backend "s3" {
    region         = "us-east-1"
    bucket         = "mit-tfstates-state"
    key            = "deploy/terraform.tfstate"
    dynamodb_table = "mit-tfstates-state-lock"
    encrypt        = true
  }
}
