locals {
  env = "${terraform.workspace}"

  shared_alb_dns = {
    "stage" = "${module.shared.alb_restricted_dnsname}"
    "prod"  = "${module.shared.alb_public_dnsname}"
  }

  shared_alb_listeners = {
    "stage" = "${module.shared.alb_restricted_https_listener_arn}"
    "prod"  = "${module.shared.alb_public_https_listener_arn}"
  }

  shared_alb_sgids = {
    "stage" = "${module.shared.alb_restricted_sgid}"
    "prod"  = "${module.shared.alb_public_sgid}"
  }
}

module "label_geoserver" {
  source = "git::https://github.com/MITLibraries/tf-mod-name?ref=master"
  name   = "geoserver"
}

module "ecr" {
  source = "git::https://github.com/MITLibraries/tf-mod-ecr?ref=master"
  name   = "geoserver"
}

# Create target group and ALB ingress rule for our container
module "alb_ingress" {
  source              = "git::https://github.com/MITLibraries/tf-mod-alb-ingress?ref=master"
  name                = "geoserver"
  vpc_id              = "${module.shared.vpc_id}"
  listener_arns       = ["${lookup(local.shared_alb_listeners, local.env)}"]
  listener_arns_count = 1
  target_type         = "instance"
  hosts               = ["${aws_route53_record.dns.name}"]
  port                = 8080
  priority            = 101
  health_check_path   = "/geoserver"
}

# Create a Route53 DNS entry to our ALB
resource "aws_route53_record" "dns" {
  zone_id = "${module.shared.public_zoneid}"
  name    = "${module.label_geoserver.name}.mitlib.net"
  type    = "CNAME"
  ttl     = "300"
  records = ["${lookup(local.shared_alb_dns, local.env)}"]
}

# Create log_group to store container logs
resource "aws_cloudwatch_log_group" "default" {
  name              = "${module.label_geoserver.name}"
  tags              = "${module.label_geoserver.tags}"
  retention_in_days = 30
}

resource "aws_ssm_parameter" "geoserver_password" {
  name  = "${module.label_geoserver.name}-password"
  tags  = "${module.label_geoserver.tags}"
  type  = "SecureString"
  value = "${var.geoserver_password}"
}

data "template_file" "default" {
  template = "${file("${path.module}/task.json")}"

  vars = {
    name               = "${module.label_geoserver.name}"
    image              = "${module.ecr.registry_url}"
    log_group          = "${aws_cloudwatch_log_group.default.name}"
    geoserver_password = "${aws_ssm_parameter.geoserver_password.arn}"
  }
}

resource "aws_ecs_service" "geoserver" {
  name            = "${module.label_geoserver.name}"
  cluster         = "${aws_ecs_cluster.default.id}"
  task_definition = "${aws_ecs_task_definition.geoserver.arn}"
  desired_count   = 1

  load_balancer {
    target_group_arn = "${module.alb_ingress.target_group_arn}"
    container_name   = "${module.label_geoserver.name}"
    container_port   = 8080
  }
}

resource "aws_ecs_task_definition" "geoserver" {
  family                   = "${module.label_geoserver.name}"
  container_definitions    = "${data.template_file.default.rendered}"
  requires_compatibilities = ["EC2"]
  tags                     = "${module.label_geoserver.tags}"
  execution_role_arn       = "${aws_iam_role.geosrv_exec.arn}"
  network_mode             = "bridge"
}

data "aws_iam_policy_document" "ssm" {
  statement {
    actions   = ["ssm:GetParameters"]
    resources = ["${aws_ssm_parameter.geoserver_password.arn}"]
  }
}

data "aws_iam_policy_document" "ecs_task_exec" {
  statement {
    actions = ["sts:AssumeRole"]

    principals = {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "geosrv_exec" {
  name               = "${module.label_geoserver.name}-exec"
  tags               = "${module.label.tags}"
  description        = "${module.label_geoserver.name} task execution role"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_task_exec.json}"
}

resource "aws_iam_role_policy" "geosrv_exec_attach" {
  name   = "${module.label_geoserver.name}-exec-policy"
  role   = "${aws_iam_role.geosrv_exec.name}"
  policy = "${data.aws_iam_policy_document.ssm.json}"
}

resource "aws_iam_role_policy_attachment" "ecs_login_attach" {
  role       = "${aws_iam_role.geosrv_exec.name}"
  policy_arn = "${module.ecr.policy_login_arn}"
}

resource "aws_iam_role_policy_attachment" "ecs_read_attach" {
  role       = "${aws_iam_role.geosrv_exec.name}"
  policy_arn = "${module.ecr.policy_read_arn}"
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

resource "aws_iam_role_policy" "cloudwatch_attach" {
  name   = "${module.label_geoserver.name}-cloudwatch"
  role   = "${aws_iam_role.geosrv_exec.name}"
  policy = "${data.aws_iam_policy_document.cloudwatch_policy.json}"
}
