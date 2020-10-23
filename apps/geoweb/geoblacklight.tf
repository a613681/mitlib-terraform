module "label_geoblacklight" {
  source = "github.com/mitlibraries/tf-mod-name?ref=0.12"
  name   = "geoblacklight"
}

module "geoblacklight_ecr" {
  source = "github.com/mitlibraries/tf-mod-ecr?ref=0.12"
  name   = "geoblacklight"
}

resource "aws_lb_listener_rule" "geoblacklight" {
  listener_arn = lookup(local.shared_alb_listeners, local.env)
  priority     = 107

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.geoblacklight.arn
  }

  condition {
    field  = "host-header"
    values = [var.geoblacklight_public_domain]
  }
}

resource "aws_lb_target_group" "geoblacklight" {
  name        = module.label_geoblacklight.name
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = module.shared.vpc_id
  target_type = "ip"

  deregistration_delay = "15"

  health_check {
    path    = "/"
    matcher = "200-399"
    port    = 3000
  }

  lifecycle {
    create_before_destroy = true
  }
}

###
# The four following rules can probably be removed at some point, but there's
# no real cost to us maintaining them. They can be consolidated into two rules
# once https://github.com/terraform-providers/terraform-provider-aws/pull/8268
# is merged.
###
resource "aws_lb_listener_rule" "geoblacklight_redirect_wms_1" {
  listener_arn = lookup(local.shared_alb_listeners, local.env)
  priority     = 103

  action {
    type             = "redirect"
    target_group_arn = aws_lb_target_group.geoblacklight.arn

    redirect {
      protocol    = "HTTPS"
      status_code = "HTTP_301"
      path        = "/ogc/wms"
    }
  }

  condition {
    field  = "host-header"
    values = [var.geoblacklight_public_domain]
  }

  condition {
    field  = "path-pattern"
    values = ["/geoserver/wms"]
  }
}

resource "aws_lb_listener_rule" "geoblacklight_redirect_wms_2" {
  listener_arn = lookup(local.shared_alb_listeners, local.env)
  priority     = 104

  action {
    type             = "redirect"
    target_group_arn = aws_lb_target_group.geoblacklight.arn

    redirect {
      protocol    = "HTTPS"
      status_code = "HTTP_301"
      path        = "/ogc/wms"
    }
  }

  condition {
    field  = "host-header"
    values = [var.geoblacklight_public_domain]
  }

  condition {
    field  = "path-pattern"
    values = ["/mitgeoserver/wms"]
  }
}

resource "aws_lb_listener_rule" "geoblacklight_redirect_wfs_1" {
  listener_arn = lookup(local.shared_alb_listeners, local.env)
  priority     = 105

  action {
    type             = "redirect"
    target_group_arn = aws_lb_target_group.geoblacklight.arn

    redirect {
      protocol    = "HTTPS"
      status_code = "HTTP_301"
      path        = "/ogc/wfs"
    }
  }

  condition {
    field  = "host-header"
    values = [var.geoblacklight_public_domain]
  }

  condition {
    field  = "path-pattern"
    values = ["/geoserver/wfs"]
  }
}

resource "aws_lb_listener_rule" "geoblacklight_redirect_wfs_2" {
  listener_arn = lookup(local.shared_alb_listeners, local.env)
  priority     = 106

  action {
    type             = "redirect"
    target_group_arn = aws_lb_target_group.geoblacklight.arn

    redirect {
      protocol    = "HTTPS"
      status_code = "HTTP_301"
      path        = "/ogc/wfs"
    }
  }

  condition {
    field  = "host-header"
    values = [var.geoblacklight_public_domain]
  }

  condition {
    field  = "path-pattern"
    values = ["/mitgeoserver/wfs"]
  }
}

# Create a Route53 DNS entry to our ALB
resource "aws_route53_record" "geoblacklight" {
  zone_id = module.shared.public_zoneid
  name    = var.geoblacklight_internal_domain
  type    = "A"

  alias {
    name                   = lookup(local.shared_alb_dns, local.env)
    zone_id                = lookup(local.shared_alb_zoneid, local.env)
    evaluate_target_health = false
  }
}

resource "aws_ssm_parameter" "secret_key" {
  name  = "${module.label_geoblacklight.name}-secret-key"
  tags  = module.label_geoblacklight.tags
  type  = "SecureString"
  value = var.secret_key
}

resource "aws_ssm_parameter" "postgres_password" {
  name  = "${module.label_geoblacklight.name}-postgres-password"
  tags  = module.label_geoblacklight.tags
  type  = "SecureString"
  value = var.postgres_password
}

resource "aws_ssm_parameter" "gbl_download_secret" {
  name  = "${module.label_geoblacklight.name}-gbl-secret"
  tags  = module.label_geoblacklight.tags
  type  = "SecureString"
  value = aws_iam_access_key.gbl_downloader.secret
}

resource "aws_ssm_parameter" "sp_private_key" {
  name  = "${module.label_geoblacklight.name}-sp-private-key"
  tags  = module.label_geoblacklight.tags
  type  = "SecureString"
  value = var.sp_private_key
}

data "template_file" "geoblacklight" {
  template = file("${path.module}/tasks/geoblacklight.json")

  vars = {
    name                = module.label_geoblacklight.name
    image               = module.geoblacklight_ecr.registry_url
    log_group           = aws_cloudwatch_log_group.default.name
    secret_key          = aws_ssm_parameter.secret_key.arn
    postgres_database   = var.postgres_database
    postgres_host       = module.rds.hostname[0]
    postgres_user       = var.postgres_username
    postgres_password   = aws_ssm_parameter.postgres_password.arn
    solr_url            = "http://${module.solr.fqdn}:8983/solr/geoweb"
    ogc_proxy_host      = "http://${module.geoserver.fqdn}:8080"
    ogc_proxy_username  = var.geoserver_username
    ogc_proxy_password  = aws_ssm_parameter.geoserver_password.arn
    download_bucket     = module.geoweb_upload.bucket_id
    download_access_key = aws_iam_access_key.gbl_downloader.id
    download_secret_key = aws_ssm_parameter.gbl_download_secret.arn
    rails_max_threads   = var.rails_max_threads
    rails_auth_type     = var.rails_auth_type
    idp_metadata_url    = var.idp_metadata_url
    idp_entity_id       = var.idp_entity_id
    idp_sso_url         = var.idp_sso_url
    sp_entity_id        = var.sp_entity_id
    urn_email           = var.urn_email
    sp_certificate      = var.sp_certificate
    sp_private_key      = aws_ssm_parameter.sp_private_key.arn
  }
}

data "aws_iam_policy_document" "geoblacklight_ssm" {
  statement {
    actions = ["ssm:GetParameters"]

    resources = [
      aws_ssm_parameter.secret_key.arn,
      aws_ssm_parameter.postgres_password.arn,
      aws_ssm_parameter.geoserver_password.arn,
      aws_ssm_parameter.gbl_download_secret.arn,
      aws_ssm_parameter.sp_private_key.arn,
    ]
  }
}

resource "aws_iam_role" "geoblacklight" {
  name               = "${module.label_geoblacklight.name}-task"
  tags               = module.label_geoblacklight.tags
  description        = "${module.label_geoblacklight.name} task role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_exec.json
}

resource "aws_iam_role_policy_attachment" "geoblacklight_task_exec" {
  role       = aws_iam_role.geoblacklight.name
  policy_arn = data.aws_iam_policy.ecs_exec.arn
}

resource "aws_iam_role_policy" "geoblacklight_ssm" {
  name   = "${module.label_geoblacklight.name}-ssm"
  role   = aws_iam_role.geoblacklight.name
  policy = data.aws_iam_policy_document.geoblacklight_ssm.json
}

resource "aws_ecs_cluster" "geoblacklight" {
  name = module.label_geoblacklight.name
  tags = module.label_geoblacklight.tags
}

resource "aws_security_group" "geoblacklight" {
  vpc_id      = module.shared.vpc_id
  name        = module.label_geoblacklight.name
  description = "Allow ingress from ALB on port 3000"
  tags        = module.label_geoblacklight.tags

  ingress {
    from_port       = 3000
    to_port         = 3000
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

resource "aws_ecs_task_definition" "geoblacklight" {
  family                   = module.label_geoblacklight.name
  container_definitions    = data.template_file.geoblacklight.rendered
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.geoblacklight.arn
  network_mode             = "awsvpc"
  cpu                      = var.geoblacklight_cpu
  memory                   = var.geoblacklight_memory
  tags                     = module.label_geoblacklight.tags
}

resource "aws_ecs_service" "geoblacklight" {
  name            = module.label_geoblacklight.name
  cluster         = aws_ecs_cluster.geoblacklight.id
  task_definition = aws_ecs_task_definition.geoblacklight.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.geoblacklight.arn
    container_name   = module.label_geoblacklight.name
    container_port   = 3000
  }

  network_configuration {
    subnets         = module.shared.private_subnets
    security_groups = [aws_security_group.geoblacklight.id]
  }

  tags = module.label_geoblacklight.tags
}

data "template_file" "geoblacklight_cleanup" {
  template = file("${path.module}/tasks/geoblacklight-cleanup.json")

  vars = {
    name        = "${module.label_geoblacklight.name}-cleanup"
    image       = "postgres:alpine"
    log_group   = aws_cloudwatch_log_group.default.name
    pg_user     = var.postgres_username
    pg_host     = module.rds.hostname[0]
    pg_name     = var.postgres_database
    pg_password = aws_ssm_parameter.postgres_password.arn
  }
}

resource "aws_ecs_task_definition" "geoblacklight_cleanup" {
  family                   = "${module.label_geoblacklight.name}-cleanup"
  container_definitions    = data.template_file.geoblacklight_cleanup.rendered
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.geoblacklight.arn
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  tags                     = module.label_geoblacklight.tags
}

resource "aws_cloudwatch_event_rule" "geoblacklight_cleanup" {
  name                = "${module.label_geoblacklight.name}-cleanup"
  description         = "Geoblacklight database cleanup"
  is_enabled          = true
  schedule_expression = "cron(0 6 * * ? *)"
  tags                = module.label_geoblacklight.tags
}

resource "aws_cloudwatch_event_target" "geoblacklight_cleanup" {
  rule     = aws_cloudwatch_event_rule.geoblacklight_cleanup.name
  arn      = aws_ecs_cluster.slingshot.arn
  role_arn = aws_iam_role.cloudwatch_task_role.arn

  ecs_target {
    launch_type         = "FARGATE"
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.geoblacklight_cleanup.arn

    network_configuration {
      subnets         = module.shared.private_subnets
      security_groups = [aws_security_group.geoblacklight.id]
    }
  }
}
