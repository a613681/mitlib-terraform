module "label" {
  source = "github.com/mitlibraries/tf-mod-name?ref=0.11"
  name   = "cantaloupe"
}

# Create ECR repository
module "ecr" {
  source = "github.com/mitlibraries/tf-mod-ecr?ref=0.11"
  name   = "cantaloupe"
}

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
    "prod"  = "${module.shared.alb_public_all_ingress_sgid}"
  }
}

# Create a Route53 DNS entry to our ALB
resource "aws_route53_record" "dns" {
  zone_id = "${module.shared.public_zoneid}"
  name    = "${module.label.name}.mitlib.net"
  type    = "CNAME"
  ttl     = "300"
  records = ["${lookup(local.shared_alb_dns, local.env)}"]
}

resource "aws_lb_listener_rule" "default" {
  listener_arn = "${lookup(local.shared_alb_listeners, local.env)}"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.default.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.dns.name}"]
  }
}

resource "aws_lb_target_group" "default" {
  name        = "${module.label.name}"
  port        = 8182
  protocol    = "HTTP"
  vpc_id      = "${module.shared.vpc_id}"
  target_type = "ip"

  deregistration_delay = "15"

  health_check {
    path    = "/"
    matcher = "200-399"
    port    = 8182
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create log_group to store container logs
resource "aws_cloudwatch_log_group" "app" {
  name              = "${module.label.name}"
  tags              = "${module.label.tags}"
  retention_in_days = 30
}

# Create App ECS cluster for Fargate task(s)
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${module.label.name}-cluster"
  tags = "${module.label.tags}"
}

resource "aws_ecs_task_definition" "default" {
  family                   = "${module.label.name}"
  tags                     = "${module.label.tags}"
  container_definitions    = "${data.template_file.default.rendered}"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = "${aws_iam_role.default.arn}"
  network_mode             = "awsvpc"
  cpu                      = 2048
  memory                   = 4096
}

resource "aws_ecs_service" "default" {
  name            = "${module.label.name}"
  tags            = "${module.label.tags}"
  cluster         = "${aws_ecs_cluster.ecs_cluster.id}"
  task_definition = "${aws_ecs_task_definition.default.arn}"
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = "${aws_lb_target_group.default.arn}"
    container_name   = "${module.label.name}"
    container_port   = 8182
  }

  network_configuration {
    subnets         = ["${module.shared.private_subnets}"]
    security_groups = ["${aws_security_group.default.id}"]
  }
}

data "template_file" "default" {
  template = "${file("${path.module}/task.json")}"
  vars = {
    name          = "${module.label.name}"
    image         = "${module.ecr.registry_url}"
    log_group     = "${aws_cloudwatch_log_group.app.name}"
    source_bucket = "${module.s3store.bucket_id}"
    cache_bucket  = "${module.s3cache.bucket_id}"
    source_key    = "${aws_ssm_parameter.source_key.arn}"
    source_secret = "${aws_ssm_parameter.source_secret.arn}"
    cache_key     = "${aws_ssm_parameter.cache_key.arn}"
    cache_secret  = "${aws_ssm_parameter.cache_secret.arn}"
  }
}

resource "aws_ssm_parameter" "source_key" {
  name  = "${module.label.name}-source-key"
  tags  = "${module.label.tags}"
  type  = "SecureString"
  value = "${aws_iam_access_key.s3store.id}"
}

resource "aws_ssm_parameter" "source_secret" {
  name  = "${module.label.name}-source-secret"
  tags  = "${module.label.tags}"
  type  = "SecureString"
  value = "${aws_iam_access_key.s3store.secret}"
}

resource "aws_ssm_parameter" "cache_key" {
  name  = "${module.label.name}-cache-key"
  tags  = "${module.label.tags}"
  type  = "SecureString"
  value = "${aws_iam_access_key.s3cache.id}"
}

resource "aws_ssm_parameter" "cache_secret" {
  name  = "${module.label.name}-cache-secret"
  tags  = "${module.label.tags}"
  type  = "SecureString"
  value = "${aws_iam_access_key.s3cache.secret}"
}

resource "aws_security_group" "default" {
  name        = "${module.label.name}"
  tags        = "${module.label.tags}"
  description = "Cantaloupe ingress on port 8182"
  vpc_id      = "${module.shared.vpc_id}"

  ingress {
    from_port       = 8182
    to_port         = 8182
    protocol        = "tcp"
    security_groups = ["${lookup(local.shared_alb_sgids, local.env)}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
