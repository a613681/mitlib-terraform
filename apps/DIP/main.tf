provider "aws" {
  version = "~> 1.51.0 "
  region  = "us-east-1"
}

#Tell terraform to use the S3 bucket and DynamoDB we created
terraform {
  required_version = ">= 0.11.10"

  backend "s3" {
    region         = "us-east-1"
    bucket         = "mit-tfstates-state"
    key            = "apps/dip.tfstate"
    dynamodb_table = "mit-tfstates-state-lock"
    encrypt        = true
  }
}
