module "label" {
  source = "github.com/mitlibraries/tf-mod-name?ref=0.12"
  name   = "dos"
}

resource "aws_cloudwatch_log_group" "default" {
  name              = module.label.name
  tags              = module.label.tags
  retention_in_days = 30
}

# A minimally configured S3 bucket. Lifecycle, encryption, web access, and
# replication configuration should be considered as the project progresses
resource "aws_s3_bucket" "default" {
  bucket = module.label.name
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = module.label.tags
}

##==-- RDS Instance --==##
resource "aws_db_instance" "default" {
  identifier                  = module.label.name
  engine                      = "postgres"
  engine_version              = "11.1"
  allocated_storage           = var.postgres_storage_size
  storage_type                = "gp2"
  instance_class              = var.postgres_instance_type
  name                        = "dos"
  username                    = var.postgres_username
  password                    = var.postgres_password
  db_subnet_group_name        = aws_db_subnet_group.default.name
  vpc_security_group_ids      = [aws_security_group.rds.id]
  allow_major_version_upgrade = false
  parameter_group_name        = aws_db_parameter_group.default.name
  backup_retention_period     = 30
  backup_window               = "03:00-04:00"
  maintenance_window          = "Mon:04:00-Mon:05:00"
  apply_immediately           = true
  tags                        = module.label.tags
}

resource "aws_db_subnet_group" "default" {
  name        = module.label.name
  description = "DOS DB subnet group"
  subnet_ids  = module.shared.private_subnets
  tags        = module.label.tags
}

resource "aws_db_parameter_group" "default" {
  name   = module.label.name
  family = "postgres11"
  tags   = module.label.tags
}

##==-- Fargate configuration --==##
module "ecr" {
  source = "github.com/mitlibraries/tf-mod-ecr?ref=0.12"
  name   = "dos"
}

resource "aws_lb_listener_rule" "default" {
  listener_arn = lookup(local.shared_alb_listeners, local.env)
  priority     = 220

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

resource "aws_ecs_cluster" "default" {
  name = module.label.name
  tags = module.label.tags
}

resource "aws_ssm_parameter" "postgres_password" {
  name  = "${module.label.name}-postgres-password"
  tags  = module.label.tags
  type  = "SecureString"
  value = var.postgres_password
}

resource "aws_ecs_task_definition" "default" {
  family = module.label.name
  tags   = module.label.tags
  container_definitions = templatefile(
    "${path.module}/task.json",
    {
      "name"              = module.label.name
      "image"             = module.ecr.registry_url
      "log_group"         = aws_cloudwatch_log_group.default.name
      "postgres_host"     = aws_db_instance.default.endpoint
      "postgres_db"       = aws_db_instance.default.name
      "postgres_username" = var.postgres_username
      "postgres_password" = aws_ssm_parameter.postgres_password.arn
  })
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs.arn
  task_role_arn            = aws_iam_role.default.arn
  network_mode             = "awsvpc"
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_mem
}

resource "aws_ecs_service" "default" {
  name            = module.label.name
  tags            = module.label.tags
  cluster         = aws_ecs_cluster.default.id
  task_definition = aws_ecs_task_definition.default.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.default.arn
    container_name   = module.label.name
    container_port   = 8080
  }

  network_configuration {
    subnets         = module.shared.private_subnets
    security_groups = [aws_security_group.default.id]
  }
}
