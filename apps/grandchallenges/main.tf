provider "aws" {
  version = "~> 2.6.0 "
  region  = "us-east-1"
}

#Tell terraform to use the S3 bucket and DynamoDB we created
terraform {
  required_version = ">= 0.11.10"

  backend "s3" {
    region         = "us-east-1"
    bucket         = "mit-tfstates-state"
    key            = "apps/grandchallenges.tfstate"
    dynamodb_table = "mit-tfstates-state-lock"
    encrypt        = true
  }
}
