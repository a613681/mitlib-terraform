module "label" {
  source = "github.com/mitlibraries/tf-mod-name?ref=0.12"
  name   = "analytics"
}

locals {
  env = terraform.workspace

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

# Create a Route53 DNS entry to our ALB
resource "aws_route53_record" "dns" {
  zone_id = module.shared.public_zoneid
  name    = "${module.label.name}.mitlib.net"
  type    = "CNAME"
  ttl     = "300"
  records = [lookup(local.shared_alb_dns, local.env)]
}

resource "aws_lb_listener_rule" "default" {
  listener_arn = lookup(local.shared_alb_listeners, local.env)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.dns.name]
  }
}

resource "aws_lb_target_group" "default" {
  name        = module.label.name
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.shared.vpc_id
  target_type = "ip"

  deregistration_delay = "15"

  health_check {
    path    = "/"
    matcher = "200-399"
    port    = 80
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create log_group to store container logs
resource "aws_cloudwatch_log_group" "app" {
  name              = module.label.name
  tags              = module.label.tags
  retention_in_days = 30
}


