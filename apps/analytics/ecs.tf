module "ecr" {
  source = "github.com/mitlibraries/tf-mod-ecr?ref=0.12"
  name   = "analytics"
}

resource "aws_ecs_cluster" "default" {
  name = "${module.label.name}-cluster"
  tags = module.label.tags
}

resource "aws_ecs_task_definition" "default" {
  family                   = module.label.name
  tags                     = module.label.tags
  container_definitions    = data.template_file.container_definitions.rendered
  requires_compatibilities = ["FARGATE"]
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

resource "aws_ecs_service" "default" {
  name             = module.label.name
  tags             = module.label.tags
  platform_version = "1.4.0"
  cluster          = aws_ecs_cluster.default.id
  task_definition  = aws_ecs_task_definition.default.arn
  desired_count    = 1
  launch_type      = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.default.arn
    container_name   = module.label.name
    container_port   = 80
  }

  network_configuration {
    subnets         = module.shared.private_subnets
    security_groups = [aws_security_group.default.id]
  }
}

data "template_file" "container_definitions" {
  template = file("${path.module}/container_definitions.json")
  vars = {
    name                          = module.label.name
    image                         = module.ecr.registry_url
    log_group                     = aws_cloudwatch_log_group.app.name
    log_prefix                    = "analytics"
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
  }
}


resource "aws_security_group" "default" {
  name        = module.label.name
  tags        = module.label.tags
  description = "Matomo ingress on port 80"
  vpc_id      = module.shared.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
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

