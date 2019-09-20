module "bucket" {
  source = "github.com/mitlibraries/tf-mod-s3-iam?ref=0.11"
  name   = "deploy-mitlib"
}
