resource "aws_ecs_task_definition" "archive_reports" {
  family                   = "${module.label.name}-archive-reports"
  tags                     = module.label.tags
  container_definitions    = data.template_file.cronjob_container_definitions.rendered
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.task_role.arn
  execution_role_arn       = aws_iam_role.default.arn
  network_mode             = "awsvpc"
  cpu                      = 2048
  memory                   = 4096
  volume {
    name = module.label.name

    efs_volume_configuration {
      file_system_id = aws_efs_file_system.default.id
      root_directory = "/"
    }
  }
}

resource "aws_iam_role" "task_role" {
  name               = "${module.label.name}-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
  description        = "Role used by scheduled task running in container"
  tags               = module.label.tags
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "template_file" "cronjob_container_definitions" {
  template = file("${path.module}/cronjob_container_definitions.json")
  vars = {
    name                          = module.label.name
    image                         = module.ecr.registry_url
    log_group                     = aws_cloudwatch_log_group.app.name
    log_prefix                    = "reports"
    mysql_user                    = var.mysql_user
    mysql_database_name           = aws_db_instance.default.name
    matomo_database_host          = aws_db_instance.default.endpoint
    mysql_password                = aws_ssm_parameter.mysql_password.arn
    matomo_database_adapter       = var.matomo_database_adapter
    matomo_database_tables_prefix = var.matomo_database_tables_prefix
    matomo_database_username      = var.matomo_database_username
    matomo_database_dbname        = var.matomo_database_dbname
    matomo_database_password      = aws_ssm_parameter.matomo_database_password.arn
    container_port                = 80
    awslogs_region                = var.awslogs_region
    file_system_id                = aws_efs_file_system.default.id
    efs_volume                    = module.label.name
    efs_mount                     = var.mount
    trusted_hosts                 = aws_route53_record.dns.name
    salt                          = var.salt
    noreply_email_address         = var.noreply_email_address
    smtp_port                     = var.smtp_port
    smtp_host                     = var.smtp_host
    smtp_user                     = var.smtp_user
    smtp_auth_type                = var.smtp_auth_type
    smtp_password                 = aws_ssm_parameter.smtp_password.arn
  }
}

resource "aws_cloudwatch_event_rule" "cron" {
  tags                = module.label.tags
  description         = "Analytics archive reports"
  schedule_expression = var.schedule_expression
  is_enabled          = true
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
  rule     = aws_cloudwatch_event_rule.cron.name
  arn      = aws_ecs_cluster.default.arn
  role_arn = aws_iam_role.cloudwatch_task_role.arn

  ecs_target {
    launch_type         = "FARGATE"
    platform_version    = "1.4.0"
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.archive_reports.arn

    network_configuration {
      subnets         = module.shared.private_subnets
      security_groups = [aws_security_group.default.id]
    }
  }
}

resource "aws_iam_role" "cloudwatch_task_role" {
  name               = "${module.label.name}-scheduled-task-role"
  tags               = module.label.tags
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_assume_role.json
  description        = "Cloudwatch role for Analytics cron"
}


data "aws_iam_policy_document" "cloudwatch_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "ecs_run_attach" {
  name   = "${module.label.name}-ecs-run"
  role   = aws_iam_role.cloudwatch_task_role.name
  policy = data.aws_iam_policy_document.cloudwatch_run_task_policy.json
}

data "aws_iam_policy_document" "cloudwatch_run_task_policy" {
  statement {
    actions = [
      "ecs:RunTask",
      "iam:PassRole",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "cron_ssm" {
  name   = "${module.label.name}-cron_ssm-policy"
  role   = aws_iam_role.task_role.name
  policy = data.aws_iam_policy_document.ssm.json
}
