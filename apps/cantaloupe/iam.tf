resource "aws_iam_role" "default" {
  name               = "${module.label.name}"
  tags               = "${module.label.tags}"
  description        = "Cantaloupe task execution role"
  assume_role_policy = "${data.aws_iam_policy_document.default.json}"
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = "${aws_iam_role.default.name}"
  policy_arn = "${data.aws_iam_policy.default.arn}"
}

resource "aws_iam_role_policy" "ssm" {
  name   = "${module.label.name}-ssm"
  role   = "${aws_iam_role.default.name}"
  policy = "${data.aws_iam_policy_document.ssm.json}"
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

data "aws_iam_policy" "default" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ssm" {
  statement {
    actions = ["ssm:GetParameters"]
    resources = [
      "${aws_ssm_parameter.source_key.arn}",
      "${aws_ssm_parameter.source_secret.arn}",
      "${aws_ssm_parameter.cache_key.arn}",
      "${aws_ssm_parameter.cache_secret.arn}"
    ]
  }
}

####### Deploy user #######
resource "aws_iam_user" "deploy" {
  name = "${module.label.name}-deploy"
  tags = "${module.label.tags}"
}

resource "aws_iam_user_policy_attachment" "ecr" {
  user       = "${aws_iam_user.deploy.name}"
  policy_arn = "${module.ecr.policy_readwrite_arn}"
}

resource "aws_iam_user_policy_attachment" "deploy" {
  user       = "${aws_iam_user.deploy.name}"
  policy_arn = "${aws_iam_policy.deploy.arn}"
}

resource "aws_iam_policy" "deploy" {
  policy = "${data.aws_iam_policy_document.deploy.json}"
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
