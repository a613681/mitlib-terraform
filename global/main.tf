provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

#Create S3 bucket and DynamoDB for locking
module "tfstate-backend" {
  source    = "cloudposse/tfstate-backend/aws"
  version   = "0.9.0"
  namespace = "mit"
  stage     = ""
  name      = "tfstates"
  region    = "us-east-1"

  tags = {
    terraform   = "true"
    environment = "global"
    Name        = "mit-tfstates-state"
  }
}

#Tell terraform to use the S3 bucket and DynamoDB we created
terraform {
  backend "s3" {
    region         = "us-east-1"
    bucket         = "mit-tfstates-state"
    key            = "global/global.tfstate"
    dynamodb_table = "mit-tfstates-state-lock"
    encrypt        = true
  }
}

