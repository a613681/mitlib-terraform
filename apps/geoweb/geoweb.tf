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

  shared_alb_zoneid = {
    "stage" = "${module.shared.alb_restricted_zone_id}"
    "prod"  = "${module.shared.alb_public_zone_id}"
  }
}

module "label" {
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

data "aws_iam_policy" "ecs_exec" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

###################
### Deploy user ###
###################

resource "aws_iam_user" "deploy" {
  name = "${module.label.name}-deploy"
  tags = "${module.label.tags}"
}

resource "aws_iam_user_policy_attachment" "slingshot_deploy_ecr" {
  user       = "${aws_iam_user.deploy.name}"
  policy_arn = "${module.slingshot_ecr.policy_readwrite_arn}"
}

resource "aws_iam_user_policy_attachment" "geoblacklight_deploy_ecr" {
  user       = "${aws_iam_user.deploy.name}"
  policy_arn = "${module.geoblacklight_ecr.policy_readwrite_arn}"
}

resource "aws_iam_access_key" "deploy" {
  user = "${aws_iam_user.deploy.name}"
}

#############
## Logging ##
#############
resource "aws_cloudwatch_log_group" "default" {
  name              = "${module.label.name}"
  tags              = "${module.label.tags}"
  retention_in_days = 30
}
