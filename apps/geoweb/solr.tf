module "label_solr" {
  source = "git::https://github.com/MITLibraries/tf-mod-name?ref=master"
  name   = "solr"
}

module "solr_ecr" {
  source = "git::https://github.com/MITLibraries/tf-mod-ecr?ref=master"
  name   = "solr"
}

# Create target group and ALB ingress rule for our container
module "solr_alb_ingress" {
  source              = "git::https://github.com/MITLibraries/tf-mod-alb-ingress?ref=master"
  name                = "solr"
  vpc_id              = "${module.shared.vpc_id}"
  listener_arns       = ["${lookup(local.shared_alb_listeners, local.env)}"]
  listener_arns_count = 1
  target_type         = "instance"
  hosts               = ["${aws_route53_record.solr_dns.name}"]
  port                = 8983
  priority            = 102
  health_check_path   = "/"
}

# Create a Route53 DNS entry to our ALB
resource "aws_route53_record" "solr_dns" {
  zone_id = "${module.shared.public_zoneid}"
  name    = "${module.label_solr.name}.mitlib.net"
  type    = "CNAME"
  ttl     = "300"
  records = ["${lookup(local.shared_alb_dns, local.env)}"]
}

# Create log_group to store container logs
resource "aws_cloudwatch_log_group" "solr" {
  name              = "${module.label_solr.name}"
  tags              = "${module.label_solr.tags}"
  retention_in_days = 30
}

data "template_file" "solrtask" {
  template = "${file("${path.module}/solrtask.json")}"

  vars = {
    name      = "${module.label_solr.name}"
    image     = "${module.solr_ecr.registry_url}"
    log_group = "${aws_cloudwatch_log_group.solr.name}"
    solr_home = "/var/solr"
  }
}

resource "aws_ecs_service" "solr" {
  name            = "${module.label_solr.name}"
  cluster         = "${aws_ecs_cluster.default.id}"
  task_definition = "${aws_ecs_task_definition.solrtask.arn}"
  desired_count   = 1

  load_balancer {
    target_group_arn = "${module.solr_alb_ingress.target_group_arn}"
    container_name   = "${module.label_solr.name}"
    container_port   = 8983
  }
}

resource "aws_ecs_task_definition" "solrtask" {
  family                   = "${module.label_solr.name}"
  container_definitions    = "${data.template_file.solrtask.rendered}"
  requires_compatibilities = ["EC2"]
  tags                     = "${module.label_solr.tags}"
  execution_role_arn       = "${aws_iam_role.solr_exec.arn}"
  network_mode             = "bridge"

  volume {
    name      = "solr_efs"
    host_path = "${local.solr_mount}"
  }
}

resource "aws_iam_role" "solr_exec" {
  name               = "${module.label_solr.name}-exec"
  tags               = "${module.label.tags}"
  description        = "${module.label_solr.name} task execution role"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_task_exec.json}"
}

resource "aws_iam_role_policy_attachment" "solr_ecs_login_attach" {
  role       = "${aws_iam_role.solr_exec.name}"
  policy_arn = "${module.solr_ecr.policy_login_arn}"
}

resource "aws_iam_role_policy_attachment" "solr_ecs_read_attach" {
  role       = "${aws_iam_role.solr_exec.name}"
  policy_arn = "${module.solr_ecr.policy_read_arn}"
}

resource "aws_iam_role_policy" "solr_cloudwatch_attach" {
  name   = "${module.label_solr.name}-cloudwatch"
  role   = "${aws_iam_role.solr_exec.name}"
  policy = "${data.aws_iam_policy_document.cloudwatch_policy.json}"
}

#######
# EFS #
#######
resource "aws_security_group" "solr_efs_sg" {
  name        = "${module.label_solr.name}-efs-sg"
  description = "Allow NFS access from Geo ECS cluster"
  tags        = "${module.label_solr.tags}"
  vpc_id      = "${module.shared.vpc_id}"

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ecs.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_efs_file_system" "solr_efs" {
  creation_token = "${module.label_solr.name}-efs"
  tags           = "${module.label_solr.tags}"
}

resource "aws_efs_mount_target" "solr_efs_mount" {
  count           = "${length(module.shared.private_subnets)}"
  file_system_id  = "${aws_efs_file_system.solr_efs.id}"
  subnet_id       = "${element(module.shared.private_subnets, count.index)}"
  security_groups = ["${aws_security_group.solr_efs_sg.id}"]
}
