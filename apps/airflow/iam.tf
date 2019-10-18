data "aws_iam_policy" "ecs_exec" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy" "ecs_autoscale" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}

data "aws_iam_policy_document" "ecs_task_exec" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "airflow_ssm" {
  statement {
    actions = ["ssm:GetParameters"]

    resources = [
      aws_ssm_parameter.sqlalchemy_conn.arn,
      aws_ssm_parameter.fernet_key.arn,
      aws_ssm_parameter.results_backend.arn,
    ]
  }
}

data "aws_iam_policy_document" "ecs_autoscale" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["application-autoscaling.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "airflow" {
  name               = "${module.label.name}-ecs"
  tags               = module.label.tags
  description        = "Task execution role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_exec.json
}

resource "aws_iam_role_policy_attachment" "airflow_task_exec" {
  role       = aws_iam_role.airflow.name
  policy_arn = data.aws_iam_policy.ecs_exec.arn
}

resource "aws_iam_role_policy" "airflow_ssm" {
  name   = "${module.label.name}-ssm"
  role   = aws_iam_role.airflow.name
  policy = data.aws_iam_policy_document.airflow_ssm.json
}

resource "aws_iam_role" "ecs_autoscale" {
  name               = "${module.label.name}-ecs-autoscale"
  tags               = module.label.tags
  description        = "ECS service autoscaling role"
  assume_role_policy = data.aws_iam_policy_document.ecs_autoscale.json
}

resource "aws_iam_role_policy_attachment" "ecs_autoscale" {
  role       = aws_iam_role.ecs_autoscale.name
  policy_arn = data.aws_iam_policy.ecs_autoscale.arn
}

####################################################################
# TASK ROLE
#
# Each container in the cluster has access to the task role. Any AWS
# API calls made from within the running container will have these
# permissions.
####################################################################
resource "aws_iam_role" "airflow_task" {
  name               = "${module.label.name}-task"
  tags               = module.label.tags
  description        = "Role that ECS task runs under"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_exec.json
}

resource "aws_iam_role_policy" "task_role" {
  name   = "${module.label.name}-task-role"
  role   = aws_iam_role.airflow_task.name
  policy = data.aws_iam_policy_document.task_role.json
}

data "aws_iam_policy_document" "task_role" {
  statement {
    actions   = ["s3:*Object", "s3:*ObjectAcl"]
    resources = ["${aws_s3_bucket.logging.arn}/*"]
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.logging.arn}"]
  }

  statement {
    actions   = ["ecs:DescribeTasks", "ecs:RunTask", "iam:PassRole"]
    resources = ["*"]
  }

  statement {
    actions   = ["ecs:StopTask"]
    resources = ["arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:task/${aws_ecs_cluster.default.name}/*"]
  }
}
