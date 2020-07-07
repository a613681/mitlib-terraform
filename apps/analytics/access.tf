resource "aws_iam_role" "default" {
  name               = module.label.name
  tags               = module.label.tags
  description        = "Fargate task execution role"
  assume_role_policy = data.aws_iam_policy_document.default.json
}

data "aws_iam_policy_document" "default" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = data.aws_iam_policy.default.arn
}

data "aws_iam_policy" "default" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

## SSM 
resource "aws_ssm_parameter" "mysql_password" {
  name  = "${module.label.name}-mysql_password"
  tags  = module.label.tags
  type  = "SecureString"
  value = var.mysql_password
}

resource "aws_ssm_parameter" "matomo_database_password" {
  name  = "${module.label.name}-matomo_database_password"
  tags  = module.label.tags
  type  = "SecureString"
  value = var.matomo_database_password
}

resource "aws_ssm_parameter" "smtp_password" {
  name  = "${module.label.name}-smtp_password"
  tags  = module.label.tags
  type  = "SecureString"
  value = var.smtp_password
}

resource "aws_iam_role_policy" "ssm" {
  name   = "${module.label.name}-ssm"
  role   = aws_iam_role.default.name
  policy = data.aws_iam_policy_document.ssm.json
}

data "aws_iam_policy_document" "ssm" {
  statement {
    actions = ["ssm:GetParameters"]

    resources = [
      aws_ssm_parameter.mysql_password.arn,
      aws_ssm_parameter.matomo_database_password.arn,
      aws_ssm_parameter.smtp_password.arn
    ]
  }
}


####### Deploy user #######
resource "aws_iam_user" "deploy" {
  name = "${module.label.name}-deploy"
  tags = module.label.tags
}

resource "aws_iam_user_policy_attachment" "ecr" {
  user       = aws_iam_user.deploy.name
  policy_arn = module.ecr.policy_readwrite_arn
}

resource "aws_iam_user_policy_attachment" "deploy" {
  user       = aws_iam_user.deploy.name
  policy_arn = aws_iam_policy.deploy.arn
}

resource "aws_iam_policy" "deploy" {
  policy = data.aws_iam_policy_document.deploy.json
}

data "aws_iam_policy_document" "deploy" {
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
