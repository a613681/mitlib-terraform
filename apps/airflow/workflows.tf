resource "aws_iam_role" "workflow_task" {
  name               = "${module.label.name}-workflow-task"
  tags               = module.label.tags
  description        = "Role for workflow tasks"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_exec.json
}

resource "aws_iam_role_policy" "aspace_rw" {
  name   = "${module.label.name}-aspace-rw"
  role   = aws_iam_role.workflow_task.name
  policy = data.aws_iam_policy_document.aspace_rw.json
}

data "aws_iam_policy_document" "aspace_rw" {
  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
    resources = [local.aspace, "${local.aspace}/*"]
    effect    = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "es_read" {
  role       = aws_iam_role.workflow_task.name
  policy_arn = module.shared.es_read_policy_arn
}

resource "aws_iam_role_policy_attachment" "es_write" {
  role       = aws_iam_role.workflow_task.name
  policy_arn = module.shared.es_write_policy_arn
}

resource "aws_iam_role_policy" "slingshot" {
  name   = "${module.label.name}-slingshot"
  role   = aws_iam_role.workflow_task.name
  policy = data.aws_iam_policy_document.slingshot.json
}

data "aws_iam_policy_document" "slingshot" {
  statement {
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = [local.dip, "${local.dip}/*"]
  }
}

###==- Workflow task definitions -==###
resource "aws_ecs_task_definition" "example" {
  family = "${module.label.name}-example-task"
  tags   = module.label.tags
  container_definitions = templatefile(
    "${path.module}/tasks/example.json",
    {
      "log_group"  = aws_cloudwatch_log_group.default.name
      "log_prefix" = "example-task"
      "command"    = ["worker"]
  })
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.airflow.arn
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
}

resource "aws_ecs_task_definition" "mario" {
  family = "${module.label.name}-mario"
  tags   = module.label.tags
  container_definitions = templatefile(
    "${path.module}/tasks/mario.json",
    {
      "name"       = "${module.label.name}-mario"
      "image"      = local.mario
      "log_group"  = aws_cloudwatch_log_group.default.name
      "log_prefix" = "mario-task"
  })
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.airflow.arn
  task_role_arn            = aws_iam_role.workflow_task.arn
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
}

resource "aws_ecs_task_definition" "oaiharvester" {
  family = "${module.label.name}-oaiharvester"
  tags   = module.label.tags
  container_definitions = templatefile(
    "${path.module}/tasks/oaiharvester.json",
    {
      "name"       = "${module.label.name}-oaiharvester"
      "image"      = module.oaiharvester_ecr.registry_url
      "log_group"  = aws_cloudwatch_log_group.default.name
      "log_prefix" = "oaiharvester-task"
  })
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.airflow.arn
  task_role_arn            = aws_iam_role.workflow_task.arn
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
}
