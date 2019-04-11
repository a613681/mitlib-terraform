locals {
  env = "${terraform.workspace}"

  shared_alb_dns = {
    "stage" = "${module.shared.alb_restricted_dnsname}"
    "prod"  = "${module.shared.alb_public_dnsname}"
  }

  shared_alb_listeners = {
    "stage" = "${module.shared.alb_restricted_https_listener_arn}"
    "prod"  = "${module.shared.alb_public_https_listener_arn}"
  }

  shared_alb_sgids = {
    "stage" = "${module.shared.alb_restricted_sgid}"
    "prod"  = "${module.shared.alb_public_sgid}"
  }
}

module "label_geoweb" {
  source = "git::https://github.com/MITLibraries/tf-mod-name?ref=master"
  name   = "geoweb"
}

########################
# Shared IAM Documents #
########################

data "aws_iam_policy_document" "cloudwatch_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ecs_task_exec" {
  statement {
    actions = ["sts:AssumeRole"]

    principals = {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

###################
### Deploy user ###
###################

resource "aws_iam_user" "deploy" {
  name = "${module.label_geoweb.name}-deploy"
  tags = "${module.label_geoweb.tags}"
}

resource "aws_iam_user_policy_attachment" "geodeploy_ecr" {
  user       = "${aws_iam_user.deploy.name}"
  policy_arn = "${module.ecr.policy_readwrite_arn}"
}

resource "aws_iam_user_policy_attachment" "solrdeploy_ecr" {
  user       = "${aws_iam_user.deploy.name}"
  policy_arn = "${module.solr_ecr.policy_readwrite_arn}"
}

resource "aws_iam_access_key" "deploy" {
  user = "${aws_iam_user.deploy.name}"
}
