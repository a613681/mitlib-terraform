module "bucket" {
  source = "git::https://github.com/mitlibraries/tf-mod-s3-iam?ref=master"
  name   = "deploy-mitlib"
}
