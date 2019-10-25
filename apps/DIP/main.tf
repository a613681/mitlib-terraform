/**
 * # Discovery Index Pipeline
 *
 * This module contains the configuration for the Discovery Index Pipeline. The main pieces of infrastructure include several new roles and policies, along with the following:
 * 
 * * S3 bucket for the Aleph MARC upload
 * * S3 bucket for the mario-powerup Lambda deployment package
 * * ECR registry for the mario container
 * * [mario-powerup](https://github.com/MITLibraries/mario-powerup) Lambda function
 * * [mario](https://github.com/MITLibraries/mario) Fargate task
 * * User for Aleph submission with permissions to submit to the Aleph bucket
 * * User for timdex with read permissions on the Elasticsearch index
 * * User for deploying mario container and mario-power Lambda function
 * 
 * The Elasticsearch search index is created in the [shared module](https://github.com/MITLibraries/mitlib-terraform/tree/master/shared/elasticsearch).
 */
provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

#Tell terraform to use the S3 bucket and DynamoDB we created
terraform {
  backend "s3" {
    region         = "us-east-1"
    bucket         = "mit-tfstates-state"
    key            = "apps/dip.tfstate"
    dynamodb_table = "mit-tfstates-state-lock"
    encrypt        = true
  }
}

module "shared" {
  source = "github.com/mitlibraries/tf-mod-shared-provider?ref=0.12"
}

