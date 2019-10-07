data "aws_iam_policy" "ecs_exec" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
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
