module "slingshot_label" {
  source = "git::https://github.com/mitlibraries/tf-mod-name?ref=master"
  name   = "slingshot"
}

module "slingshot_ecr" {
  source = "git::https://github.com/mitlibraries/tf-mod-ecr?ref=master"
  name   = "slingshot"
}
