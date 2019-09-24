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

resource "aws_iam_access_key" "deploy" {
  user = aws_iam_user.deploy.name
}


