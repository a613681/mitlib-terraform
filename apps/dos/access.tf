##==-- Use this file for security groups, IAM roles, etc. --==##

##==-- Main DOS security group --==##
resource "aws_security_group" "default" {
  name        = module.label.name
  tags        = module.label.tags
  description = "Primary DOS security group"
  vpc_id      = module.shared.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [lookup(local.shared_alb_sgids, local.env)]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##==-- RDS security group --==##
## The database is restricted to only the DOS app and bastion hosts
resource "aws_security_group" "rds" {
  name        = "${module.label.name}-rds"
  description = "DOS RDS security group"
  tags        = module.label.tags
  vpc_id      = module.shared.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [
      module.shared.bastion_ingress_sgid,
      aws_security_group.default.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##==-- DOS app role --==##
## Use this role for any permissions the application itself will need
resource "aws_iam_role" "default" {
  name               = module.label.name
  tags               = module.label.tags
  description        = "DOS application role"
  assume_role_policy = data.aws_iam_policy_document.ecs.json
}

resource "aws_iam_role_policy" "s3" {
  name   = "${module.label.name}-s3"
  role   = aws_iam_role.default.name
  policy = data.aws_iam_policy_document.s3_rw.json
}

##==-- DOS Fargate role --==##
## This is used to start the container. Any SSM parameter permissions
## should be attached to this role.
resource "aws_iam_role" "ecs" {
  name               = "${module.label.name}-ecs"
  tags               = module.label.tags
  description        = "DOS Fargate execution role"
  assume_role_policy = data.aws_iam_policy_document.ecs.json
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = data.aws_iam_policy.ecs_exec.arn
}

resource "aws_iam_role_policy" "ecs_ssm" {
  name   = "${module.label.name}-ssm"
  role   = aws_iam_role.ecs.name
  policy = data.aws_iam_policy_document.ssm.json
}

data "aws_iam_policy_document" "ssm" {
  statement {
    actions = ["ssm:GetParameters"]

    resources = [
      aws_ssm_parameter.postgres_password.arn,
    ]
  }
}

data "aws_iam_policy_document" "ecs" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "ecs_exec" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

##==-- Developer IAM S3 user permissions --==##
resource "aws_iam_user_policy_attachment" "s3_rw" {
  count      = length(var.users)
  user       = "${var.users[count.index]}"
  policy_arn = "${aws_iam_policy.s3_rw.arn}"
}

resource "aws_iam_policy" "s3_rw" {
  name        = "${module.label.name}-s3"
  description = "Policy to allow IAM user full access to ${module.label.name} S3 bucket"
  policy      = "${data.aws_iam_policy_document.s3_rw.json}"
}

data "aws_iam_policy_document" "s3_rw" {
  statement {
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.default.arn]
  }
  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.default.arn}/*"]
  }
}

##==-- Deploy user --==##
resource "aws_iam_user" "deploy" {
  name = "${module.label.name}-deploy"
  tags = module.label.tags
}

resource "aws_iam_user_policy_attachment" "ecr" {
  user       = aws_iam_user.deploy.name
  policy_arn = module.ecr.policy_readwrite_arn
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
