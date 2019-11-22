locals {
  env = terraform.workspace

  shared_alb_dns = {
    stage = module.shared.alb_restricted_dnsname
    prod  = module.shared.alb_restricted_dnsname
  }
  shared_alb_listeners = {
    stage = module.shared.alb_restricted_https_listener_arn
    prod  = module.shared.alb_restricted_https_listener_arn
  }

  shared_alb_sgids = {
    stage = module.shared.alb_restricted_sgid
    prod  = module.shared.alb_restricted_sgid
  }

  network_config = {
    "awsvpcConfiguration" = {
      "subnets"        = module.shared.private_subnets,
      "securityGroups" = [aws_security_group.airflow_tasks.id]
    }
  }

  mario_images = {
    stage = "672626379771.dkr.ecr.us-east-1.amazonaws.com/mario-stage"
    prod  = "672626379771.dkr.ecr.us-east-1.amazonaws.com/mario-prod"
  }

  aspace_buckets = {
    stage = "arn:aws:s3:::aspace-oai-s3-stage"
    prod  = "arn:aws:s3:::aspace-oai-s3-prod"
  }

  mario  = lookup(local.mario_images, local.env)
  aspace = lookup(local.aspace_buckets, local.env)
}

module "ecr" {
  source = "github.com/mitlibraries/tf-mod-ecr?ref=0.12"
  name   = "airflow"
}

resource "aws_ecs_cluster" "default" {
  name = module.label.name
  tags = module.label.tags
}

resource "aws_ssm_parameter" "sqlalchemy_conn" {
  name  = "${module.label.name}-sqlalchemy-conn"
  tags  = module.label.tags
  type  = "SecureString"
  value = "postgresql://${var.postgres_username}:${var.postgres_password}@${aws_db_instance.default.endpoint}/${aws_db_instance.default.name}"
}

resource "aws_ssm_parameter" "results_backend" {
  name  = "${module.label.name}-results-backend"
  tags  = module.label.tags
  type  = "SecureString"
  value = "db+postgresql://${var.postgres_username}:${var.postgres_password}@${aws_db_instance.default.endpoint}/${aws_db_instance.default.name}"
}

resource "aws_ssm_parameter" "fernet_key" {
  name  = "${module.label.name}-fernet-key"
  tags  = module.label.tags
  type  = "SecureString"
  value = var.airflow_fernet_key
}

resource "aws_security_group" "airflow" {
  name        = "${module.label.name}"
  tags        = module.label.tags
  description = "Airflow cluster"
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

###==- Airflow web UI -==###
resource "aws_lb_listener_rule" "default" {
  listener_arn = lookup(local.shared_alb_listeners, local.env)
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.default.fqdn]
  }
}

resource "aws_lb_target_group" "default" {
  name                 = module.label.name
  port                 = 8080
  protocol             = "HTTP"
  vpc_id               = module.shared.vpc_id
  target_type          = "ip"
  deregistration_delay = 15

  health_check {
    path    = "/"
    matcher = "200-399"
    port    = 8080
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "default" {
  name    = module.label.name
  zone_id = module.shared.public_zoneid
  type    = "CNAME"
  ttl     = 300
  records = [lookup(local.shared_alb_dns, local.env)]
}

resource "aws_ecs_task_definition" "web" {
  family = "${module.label.name}-web"
  tags   = module.label.tags
  container_definitions = templatefile(
    "${path.module}/tasks/airflow.json",
    {
      "name"            = "${module.label.name}-web"
      "image"           = module.ecr.registry_url
      "log_group"       = aws_cloudwatch_log_group.default.name
      "log_prefix"      = "web"
      "sqlalchemy_conn" = aws_ssm_parameter.sqlalchemy_conn.arn
      "fernet_key"      = aws_ssm_parameter.fernet_key.arn
      "command"         = ["webserver"]
      "force_kill"      = 30
      "redis_node"      = "redis://${aws_elasticache_cluster.redis.cache_nodes.0.address}:${aws_elasticache_cluster.redis.cache_nodes.0.port}"
      "results_backend" = aws_ssm_parameter.results_backend.arn
      "network_config"  = local.network_config
      "cluster"         = aws_ecs_cluster.default.name
      "es_url"          = "https://${module.shared.es_endpoint}"
      "environment"     = local.env
  })
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.airflow.arn
  task_role_arn            = aws_iam_role.airflow_task.arn
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 1024
}

resource "aws_ecs_service" "web" {
  name            = "${module.label.name}-web"
  tags            = module.label.tags
  cluster         = aws_ecs_cluster.default.id
  task_definition = aws_ecs_task_definition.web.arn
  desired_count   = 0
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.default.arn
    container_name   = "${module.label.name}-web"
    container_port   = 8080
  }

  network_configuration {
    subnets         = module.shared.private_subnets
    security_groups = [aws_security_group.airflow.id]
  }

  lifecycle {
    ignore_changes = ["desired_count"]
  }
}

###==- Airflow Scheduler -==###
resource "aws_ecs_task_definition" "scheduler" {
  family = "${module.label.name}-scheduler"
  tags   = module.label.tags
  container_definitions = templatefile(
    "${path.module}/tasks/airflow.json",
    {
      "name"            = "${module.label.name}-scheduler"
      "image"           = module.ecr.registry_url
      "log_group"       = aws_cloudwatch_log_group.default.name
      "log_prefix"      = "scheduler"
      "sqlalchemy_conn" = aws_ssm_parameter.sqlalchemy_conn.arn
      "fernet_key"      = aws_ssm_parameter.fernet_key.arn
      "command"         = ["scheduler"]
      "force_kill"      = 30
      "redis_node"      = "redis://${aws_elasticache_cluster.redis.cache_nodes.0.address}:${aws_elasticache_cluster.redis.cache_nodes.0.port}"
      "results_backend" = aws_ssm_parameter.results_backend.arn
      "network_config"  = local.network_config
      "cluster"         = aws_ecs_cluster.default.name
      "es_url"          = "https://${module.shared.es_endpoint}"
      "environment"     = local.env
  })
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.airflow.arn
  task_role_arn            = aws_iam_role.airflow_task.arn
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
}

resource "aws_ecs_service" "scheduler" {
  name            = "${module.label.name}-scheduler"
  tags            = module.label.tags
  cluster         = aws_ecs_cluster.default.id
  task_definition = aws_ecs_task_definition.scheduler.arn
  desired_count   = 0
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = module.shared.private_subnets
    security_groups = [aws_security_group.airflow.id]
  }

  lifecycle {
    ignore_changes = ["desired_count"]
  }
}

###==- Airflow Worker -==###
resource "aws_ecs_task_definition" "worker" {
  family = "${module.label.name}-worker"
  tags   = module.label.tags
  container_definitions = templatefile(
    "${path.module}/tasks/airflow.json",
    {
      "name"            = "${module.label.name}-worker"
      "image"           = module.ecr.registry_url
      "log_group"       = aws_cloudwatch_log_group.default.name
      "log_prefix"      = "worker"
      "sqlalchemy_conn" = aws_ssm_parameter.sqlalchemy_conn.arn
      "fernet_key"      = aws_ssm_parameter.fernet_key.arn
      "command"         = ["worker"]
      "force_kill"      = 120
      "redis_node"      = "redis://${aws_elasticache_cluster.redis.cache_nodes.0.address}:${aws_elasticache_cluster.redis.cache_nodes.0.port}"
      "results_backend" = aws_ssm_parameter.results_backend.arn
      "network_config"  = local.network_config
      "cluster"         = aws_ecs_cluster.default.name
      "es_url"          = "https://${module.shared.es_endpoint}"
      "environment"     = local.env
  })
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.airflow.arn
  task_role_arn            = aws_iam_role.airflow_task.arn
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 1024
}

resource "aws_ecs_service" "worker" {
  name            = "${module.label.name}-worker"
  tags            = module.label.tags
  cluster         = aws_ecs_cluster.default.id
  task_definition = aws_ecs_task_definition.worker.arn
  desired_count   = 0
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = module.shared.private_subnets
    security_groups = [aws_security_group.airflow.id]
  }

  lifecycle {
    ignore_changes = ["desired_count"]
  }
}

# Note that the role_arn in the aws_appautoscaling_target is currently
# broken: https://github.com/terraform-providers/terraform-provider-aws/issues/5023
# Remove the lifecyle block when this bug is fixed.
resource "aws_appautoscaling_target" "worker" {
  max_capacity       = 2
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.default.name}/${aws_ecs_service.worker.name}"
  role_arn           = aws_iam_role.ecs_autoscale.arn
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  lifecycle {
    ignore_changes = ["role_arn"]
  }
}

resource "aws_appautoscaling_policy" "worker" {
  name               = module.label.name
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.worker.resource_id
  scalable_dimension = aws_appautoscaling_target.worker.scalable_dimension
  service_namespace  = aws_appautoscaling_target.worker.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 75
    scale_in_cooldown  = 60
    scale_out_cooldown = 180

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

###==- Airflow tasks -==###
## These resources are for Airflow task containers
resource "aws_security_group" "airflow_tasks" {
  name        = "${module.label.name}-tasks"
  tags        = module.label.tags
  description = "Airflow task security group"
  vpc_id      = module.shared.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
