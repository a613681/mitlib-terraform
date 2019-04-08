module "label_geoweb" {
  source = "git::https://github.com/MITLibraries/tf-mod-name?ref=master"
  name   = "geoweb"
}

###################
### Deploy user ###
###################

resource "aws_iam_user" "deploy" {
  name = "${module.label_geoweb.name}-deploy"
  tags = "${module.label_geoweb.tags}"
}

resource "aws_iam_user_policy_attachment" "deploy_ecr" {
  user       = "${aws_iam_user.deploy.name}"
  policy_arn = "${module.ecr.policy_readwrite_arn}"
}

resource "aws_iam_access_key" "deploy" {
  user = "${aws_iam_user.deploy.name}"
}
