module "label" {
  source = "github.com/mitlibraries/tf-mod-name?ref=0.12"
  name   = "airflow"
}

resource "aws_cloudwatch_log_group" "default" {
  name              = module.label.name
  tags              = module.label.tags
  retention_in_days = 30
}

resource "aws_iam_user" "deploy" {
  name = "${module.label.name}-deploy"
  tags = module.label.tags
}

resource "aws_iam_user_policy_attachment" "airflow_deploy_ecr" {
  user       = aws_iam_user.deploy.name
  policy_arn = module.ecr.policy_readwrite_arn
}

resource "aws_iam_policy" "airflow_deploy_ecs" {
  policy = data.aws_iam_policy_document.airflow_deploy_ecs.json
}

resource "aws_iam_user_policy_attachment" "airflow_deploy_ecs" {
  user       = aws_iam_user.deploy.name
  policy_arn = aws_iam_policy.airflow_deploy_ecs.arn
}

data "aws_iam_policy_document" "airflow_deploy_ecs" {
  statement {
    actions = [
      "ecs:DescribeServices",
      "ecs:DescribeTasks",
      "ecs:RunTask",
      "ecs:UpdateService",
      "iam:PassRole",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_access_key" "deploy" {
  user = aws_iam_user.deploy.name
}

resource "aws_s3_bucket" "logging" {
  bucket = "${module.label.name}-logging"
  tags   = module.label.tags

  lifecycle_rule {
    enabled = true

    expiration {
      days = 14
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
