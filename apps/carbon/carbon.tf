locals = {
  feed_types = {
    "0" = "people"
    "1" = "articles"
  }
}

module "secret" {
  source = "git::https://github.com/mitlibraries/tf-mod-secrets?ref=master"
  name   = "carbon"
}

module "ecr" {
  source = "git::https://github.com/mitlibraries/tf-mod-ecr?ref=master"
  name   = "carbon"
}

module "label" {
  source = "git::https://github.com/mitlibraries/tf-mod-name?ref=master"
  name   = "carbon"
}

data "aws_iam_policy_document" "cloudwatch_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }
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

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals = {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cloudwatch_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals = {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "sns_publish" {
  statement {
    actions   = ["sns:Publish"]
    resources = ["${aws_sns_topic.instance-alerts.arn}"]
  }
}

/**
 * The execution role is used for the agent running the container. It needs
 * to be able to pull from ECR and write logs to Cloudwatch. This is
 * different than the task role.
 */
resource "aws_iam_role" "execution_role" {
  name               = "${module.label.name}-agent"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_task_assume_role.json}"
  description        = "Carbon role used for running container"
  tags               = "${module.label.tags}"
}

resource "aws_iam_role_policy_attachment" "ecs_login_attach" {
  role       = "${aws_iam_role.execution_role.name}"
  policy_arn = "${module.ecr.policy_login_arn}"
}

resource "aws_iam_role_policy_attachment" "ecs_read_attach" {
  role       = "${aws_iam_role.execution_role.name}"
  policy_arn = "${module.ecr.policy_read_arn}"
}

resource "aws_iam_role_policy" "cloudwatch_attach" {
  name   = "${module.label.name}-cloudwatch"
  role   = "${aws_iam_role.execution_role.name}"
  policy = "${data.aws_iam_policy_document.cloudwatch_policy.json}"
}

/**
 * The task role is used to for the app running in the container. It will
 * need whatever permissions the app itself would need to access AWS
 * resources.
 */
resource "aws_iam_role" "task_role" {
  name               = "${module.label.name}-task"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_task_assume_role.json}"
  description        = "Carbon role used by app running in container"
  tags               = "${module.label.tags}"
}

resource "aws_iam_role_policy_attachment" "secret_attach" {
  role       = "${aws_iam_role.task_role.name}"
  policy_arn = "${module.secret.read_policy}"
}

resource "aws_iam_role_policy" "sns_attach" {
  name   = "${module.label.name}-sns"
  role   = "${aws_iam_role.task_role.name}"
  policy = "${data.aws_iam_policy_document.sns_publish.json}"
}

/**
 * The Cloudwatch task role is used to run the Fargate task. It needs to be
 * able to run the ECS task.
 */
resource "aws_iam_role" "cloudwatch_task_role" {
  name               = "${module.label.name}-cloudwatch-task"
  assume_role_policy = "${data.aws_iam_policy_document.cloudwatch_assume_role.json}"
  description        = "Carbon role used for running Fargate task"
  tags               = "${module.label.tags}"
}

resource "aws_iam_role_policy" "ecs_run_attach" {
  name   = "${module.label.name}-ecs-run"
  role   = "${aws_iam_role.cloudwatch_task_role.name}"
  policy = "${data.aws_iam_policy_document.cloudwatch_run_task_policy.json}"
}

resource "aws_ecs_cluster" "default" {
  name = "${module.label.name}-cluster"
  tags = "${module.label.tags}"
}

resource "aws_cloudwatch_log_group" "default" {
  name              = "${module.label.name}-logs"
  retention_in_days = 30
}

resource "aws_security_group" "default" {
  name        = "${module.label.name}-sg"
  description = "Allow all outband traffic"

  tags = "${module.label.tags}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "task_template" {
  count    = "${length(local.feed_types)}"
  template = "${file("${path.module}/task.json")}"

  vars = {
    image     = "${module.ecr.registry_url}"
    ftp_host  = "${var.ftp_host}"
    ftp_user  = "${var.ftp_user}"
    ftp_path  = "${lookup(var.ftp_path, lookup(local.feed_types, count.index))}"
    secret_id = "${module.secret.secret}"
    sns_topic = "${aws_sns_topic.instance-alerts.arn}"
    feed_type = "${lookup(local.feed_types, count.index)}"
    log_group = "${aws_cloudwatch_log_group.default.name}"
  }
}

resource "aws_ecs_task_definition" "ecs_task" {
  count                    = "${length(local.feed_types)}"
  family                   = "${module.label.name}-${lookup(local.feed_types, count.index)}"
  container_definitions    = "${data.template_file.task_template.*.rendered[count.index]}"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = "${aws_iam_role.task_role.arn}"
  execution_role_arn       = "${aws_iam_role.execution_role.arn}"
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
}

resource "aws_cloudwatch_event_rule" "default" {
  count               = "${length(local.feed_types)}"
  name                = "${module.label.name}-${lookup(local.feed_types, count.index)}"
  schedule_expression = "${lookup(var.schedule, lookup(local.feed_types, count.index))}"
  is_enabled          = false
}

resource "aws_cloudwatch_event_target" "default" {
  count    = "${length(local.feed_types)}"
  rule     = "${aws_cloudwatch_event_rule.default.*.name[count.index]}"
  arn      = "${aws_ecs_cluster.default.arn}"
  role_arn = "${aws_iam_role.cloudwatch_task_role.arn}"

  ecs_target = {
    launch_type         = "FARGATE"
    task_count          = 1
    task_definition_arn = "${aws_ecs_task_definition.ecs_task.*.arn[count.index]}"

    network_configuration = {
      subnets         = ["${data.aws_subnet.mit_net.id}"]
      security_groups = ["${aws_security_group.default.id}"]
    }
  }
}

/**
 * Create SNS topic for notifications (Terraform can't create e-mail topics
 * since they require user verification via an e-mail)
 */
resource "aws_sns_topic" "instance-alerts" {
  name = "${module.label.name}"

  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${self.arn} --protocol email --notification-endpoint ${var.email}"
  }
}
