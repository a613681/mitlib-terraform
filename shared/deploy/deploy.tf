module "bucket" {
  source = "github.com/mitlibraries/tf-mod-s3-iam?ref=0.12"
  name   = "deploy-mitlib"
}
