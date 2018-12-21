module "label" {
  source = "git::https://github.com/MITLibraries/tf-mod-name?ref=master"
  name   = "cantaloupe"
}

# Create ECR repository
module "ecr" {
  source = "git::https://github.com/MITLibraries/tf-mod-ecr?ref=master"
  name   = "cantaloupe"
}

# Create a Route53 DNS entry to our ALB
resource "aws_route53_record" "dns" {
  zone_id = "${module.shared.public_zoneid}"
  name    = "${module.label.name}.mitlib.net"
  type    = "CNAME"
  ttl     = "300"
  records = ["${module.shared.alb_restricted_dnsname}"]
}

# Create target group and ALB ingress rule for our container
module "alb_ingress" {
  source              = "git::https://github.com/MITLibraries/tf-mod-alb-ingress?ref=master"
  name                = "cantaloupe"
  vpc_id              = "${module.shared.vpc_id}"
  listener_arns       = ["${module.shared.alb_restricted_http_listener_arn}", "${module.shared.alb_restricted_https_listener_arn}"]
  listener_arns_count = 2
  hosts               = ["cantaloupe-stage.mitlib.net"]
  port                = 8182
}

# Create log_group to store container logs
resource "aws_cloudwatch_log_group" "app" {
  name              = "${module.label.name}"
  tags              = "${module.label.tags}"
  retention_in_days = 3
}

# Create App ECS cluster for Fargate task(s)
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${module.label.name}-cluster"
  tags = "${module.label.tags}"
}

# Allow access from ALB to containers
module "all_internal_access" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "2.9.0"

  name        = "Internal VPC Access"
  description = "Allow All Internal Traffic"
  vpc_id      = "${module.shared.vpc_id}"

  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      description = "Allow all internal Access"
      cidr_blocks = "172.0.0.0/8"
    },
  ]

  tags {
    Terraform = "true"
  }
}

# Create ECS Fargate Service
module "fargate" {
  source                    = "git::https://github.com/MITLibraries/tf-mod-alb-ecs-service-task?ref=master"
  name                      = "cantaloupe"
  container_name            = "${module.label.name}"
  ecs_cluster_arn           = "${aws_ecs_cluster.ecs_cluster.arn}"
  container_definition_json = "${module.task.json}"
  task_cpu                  = "2048"
  task_memory               = "4096"
  vpc_id                    = "${module.shared.vpc_id}"
  private_subnet_ids        = "${module.shared.private_subnets}"
  alb_target_group_arn      = "${module.alb_ingress.target_group_arn}"
  security_group_ids        = ["${module.all_internal_access.this_security_group_id}"]
  container_port            = 8182
}
