module "label" {
  source = "git::https://github.com/MITLibraries/tf-mod-name?ref=master"
  name   = "cantaloupe"
}

# Create ECR repository
module "ecr" {
  source = "git::https://github.com/MITLibraries/tf-mod-ecr?ref=master"
  name   = "cantaloupe"
}

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
    "stage" = "${module.shared.alb_restricted_all_ingress_sgid}"
    "prod"  = "${module.shared.alb_public_all_ingress_sgid}"
  }
}

# Create a Route53 DNS entry to our ALB
resource "aws_route53_record" "dns" {
  zone_id = "${module.shared.public_zoneid}"
  name    = "${module.label.name}.mitlib.net"
  type    = "CNAME"
  ttl     = "300"
  records = ["${lookup(local.shared_alb_dns, local.env)}"]
}

# Create target group and ALB ingress rule for our container
module "alb_ingress" {
  source              = "git::https://github.com/MITLibraries/tf-mod-alb-ingress?ref=master"
  name                = "cantaloupe"
  vpc_id              = "${module.shared.vpc_id}"
  listener_arns       = ["${lookup(local.shared_alb_listeners, local.env)}"]
  listener_arns_count = 1
  hosts               = ["${aws_route53_record.dns.name}"]
  port                = 8182
}

# Create log_group to store container logs
resource "aws_cloudwatch_log_group" "app" {
  name              = "${module.label.name}"
  tags              = "${module.label.tags}"
  retention_in_days = 30
}

# Create App ECS cluster for Fargate task(s)
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${module.label.name}-cluster"
  tags = "${module.label.tags}"
}

# Create ECS Fargate Service
module "fargate" {
  source                    = "git::https://github.com/MITLibraries/tf-mod-alb-ecs-service-task?ref=master"
  name                      = "cantaloupe"
  container_name            = "${module.label.name}"
  ecs_cluster_arn           = "${aws_ecs_cluster.ecs_cluster.arn}"
  container_definition_json = "${module.task.json}"
  task_cpu                  = "2048"
  task_memory               = "4096"
  vpc_id                    = "${module.shared.vpc_id}"
  private_subnet_ids        = "${module.shared.private_subnets}"
  alb_target_group_arn      = "${module.alb_ingress.target_group_arn}"
  security_group_ids        = ["${lookup(local.shared_alb_sgids, local.env)}"]
  container_port            = 8182
}

###################
### Deploy user ###
###################
data "aws_iam_policy_document" "deploy_policy" {
  # allows user to deploy to ecs
  statement {
    sid = "ecs"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService",
      "sts:GetCallerIdentity",
      "events:ListTargetsByRule",
      "events:PutTargets",
    ]

    resources = [
      "*",
    ]
  }

  # allows user to run ecs task using task execution and app roles
  statement {
    sid = "AppRole"

    actions = [
      "iam:PassRole",
    ]

    resources = [
      "${module.fargate.service_role_arn}",
      "${module.fargate.task_role_arn}",
    ]
  }
}

resource "aws_iam_user" "deploy" {
  name = "${module.label.name}-deploy"
  tags = "${module.label.tags}"
}

resource "aws_iam_user_policy" "deploy" {
  user   = "${aws_iam_user.deploy.name}"
  policy = "${data.aws_iam_policy_document.deploy_policy.json}"
}

resource "aws_iam_user_policy_attachment" "deploy_ecr" {
  user       = "${aws_iam_user.deploy.name}"
  policy_arn = "${module.ecr.policy_readwrite_arn}"
}

resource "aws_iam_access_key" "deploy" {
  user = "${aws_iam_user.deploy.name}"
}
