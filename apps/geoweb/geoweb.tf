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

###################
### AWS Backup ###
##################

resource "aws_iam_role" "backup_role" {
  name = "${module.label_geoweb.name}"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "backup.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_backup" {
  role       = "${aws_iam_role.backup_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "attach_restore" {
  role       = "${aws_iam_role.backup_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

resource "aws_kms_key" "geoweb" {
  description = "KMS Key for ${module.label_geoweb.name} Backups"
  tags        = "${module.label_geoweb.tags}"
}

resource "aws_backup_vault" "geoweb" {
  name        = "${module.label_geoweb.name}"
  kms_key_arn = "${aws_kms_key.geoweb.arn}"
  tags        = "${module.label_geoweb.tags}"
}

resource "aws_backup_plan" "geoweb" {
  name = "${module.label_geoweb.name}"

  rule {
    rule_name         = "${module.label_geoweb.name}"
    target_vault_name = "${aws_backup_vault.geoweb.name}"
    schedule          = "cron(0 5 ? * * *)"

    #recovery_point_tags = "${module.label_geoweb.tags}"

    lifecycle {
      delete_after = "30"
    }
  }

  #tags = "${module.label_geoweb.tags}"
}

resource "aws_backup_selection" "geoweb" {
  name         = "${module.label_geoweb.name}"
  plan_id      = "${aws_backup_plan.geoweb.id}"
  iam_role_arn = "${aws_iam_role.backup_role.arn}"

  resources = [
    "${aws_efs_file_system.geo_efs.arn}",
    "${aws_efs_file_system.solr_efs.arn}",
  ]
}
