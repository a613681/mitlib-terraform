module "label_geoblacklight" {
  source = "git::https://github.com/MITLibraries/tf-mod-name?ref=master"
  name   = "geoblacklight"
}

module "geoblacklight_ecr" {
  source = "git::https://github.com/MITLibraries/tf-mod-ecr?ref=master"
  name   = "geoblacklight"
}

# Create target group and ALB ingress rule for our container
module "alb_ingress_geoblacklight" {
  source              = "git::https://github.com/MITLibraries/tf-mod-alb-ingress?ref=master"
  name                = "geoblacklight"
  vpc_id              = "${module.shared.vpc_id}"
  listener_arns       = ["${lookup(local.shared_alb_listeners, local.env)}"]
  listener_arns_count = 1
  hosts               = ["${aws_route53_record.geoblacklight.name}"]
  port                = 3000
  priority            = 103
  health_check_path   = "/"
}

# Create a Route53 DNS entry to our ALB
resource "aws_route53_record" "geoblacklight" {
  zone_id = "${module.shared.public_zoneid}"
  name    = "${module.label_geoblacklight.name}.mitlib.net"
  type    = "CNAME"
  ttl     = "300"
  records = ["${lookup(local.shared_alb_dns, local.env)}"]
}

# Create log_group to store container logs
resource "aws_cloudwatch_log_group" "default" {
  name              = "${module.label_geoblacklight.name}"
  tags              = "${module.label_geoblacklight.tags}"
  retention_in_days = 30
}

resource "aws_ssm_parameter" "secret_key" {
  name  = "${module.label_geoblacklight.name}-secret-key"
  tags  = "${module.label_geoblacklight.tags}"
  type  = "SecureString"
  value = "${var.secret_key}"
}

resource "aws_ssm_parameter" "postgres_password" {
  name  = "${module.label_geoblacklight.name}-postgres-password"
  tags  = "${module.label_geoblacklight.tags}"
  type  = "SecureString"
  value = "${var.postgres_password}"
}

data "template_file" "geoblacklight" {
  template = "${file("${path.module}/geoblacklight.json")}"

  vars = {
    name              = "${module.label_geoblacklight.name}"
    image             = "${module.geoblacklight_ecr.registry_url}"
    log_group         = "${aws_cloudwatch_log_group.default.name}"
    secret_key        = "${aws_ssm_parameter.secret_key.arn}"
    postgres_database = "${var.postgres_database}"
    postgres_host     = "${module.rds.hostname[0]}"
    postgres_user     = "${var.postgres_username}"
    postgres_password = "${aws_ssm_parameter.postgres_password.arn}"
    solr_url          = "http://${aws_route53_record.solr_dns.fqdn}:8983/solr/geoweb"
  }
}

data "aws_iam_policy_document" "geoblacklight_ssm" {
  statement {
    actions = ["ssm:GetParameters"]

    resources = [
      "${aws_ssm_parameter.secret_key.arn}",
      "${aws_ssm_parameter.postgres_password.arn}",
    ]
  }
}

resource "aws_iam_role" "geoblacklight" {
  name               = "${module.label_geoblacklight.name}-task"
  tags               = "${module.label_geoblacklight.tags}"
  description        = "${module.label_geoblacklight.name} task role"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_task_exec.json}"
}

resource "aws_iam_role_policy_attachment" "geoblacklight_task_exec" {
  role       = "${aws_iam_role.geoblacklight.name}"
  policy_arn = "${data.aws_iam_policy.ecs_exec.arn}"
}

resource "aws_iam_role_policy" "geoblacklight_ssm" {
  name   = "${module.label_geoblacklight.name}-ssm"
  role   = "${aws_iam_role.geoblacklight.name}"
  policy = "${data.aws_iam_policy_document.geoblacklight_ssm.json}"
}

resource "aws_ecs_cluster" "geoblacklight" {
  name = "${module.label_geoblacklight.name}"
  tags = "${module.label_geoblacklight.tags}"
}

resource "aws_security_group" "geoblacklight" {
  vpc_id      = "${module.shared.vpc_id}"
  name        = "${module.label_geoblacklight.name}"
  description = "Allow all egress from ECS service"
  tags        = "${module.label_geoblacklight.tags}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "geoblacklight" {
  family                   = "${module.label_geoblacklight.name}"
  container_definitions    = "${data.template_file.geoblacklight.rendered}"
  requires_compatibilities = ["FARGATE"]
  tags                     = "${module.label_geoblacklight.tags}"
  execution_role_arn       = "${aws_iam_role.geoblacklight.arn}"
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  tags                     = "${module.label_geoblacklight.tags}"
}

resource "aws_ecs_service" "geoblacklight" {
  name            = "${module.label_geoblacklight.name}"
  cluster         = "${aws_ecs_cluster.geoblacklight.id}"
  task_definition = "${aws_ecs_task_definition.geoblacklight.arn}"
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = "${module.alb_ingress_geoblacklight.target_group_arn}"
    container_name   = "${module.label_geoblacklight.name}"
    container_port   = 3000
  }

  network_configuration {
    subnets = ["${module.shared.private_subnets}"]

    security_groups = ["${aws_security_group.geoblacklight.id}",
      "${lookup(local.shared_alb_sgids, local.env)}",
    ]
  }

  tags = "${module.label_geoblacklight.tags}"
}
