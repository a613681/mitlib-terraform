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
    data_dir           = "/var/geoserver/data"
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

  volume {
    name      = "geo_efs"
    host_path = "${local.geoserver_mount}"
  }
}

data "aws_iam_policy_document" "ssm" {
  statement {
    actions   = ["ssm:GetParameters"]
    resources = ["${aws_ssm_parameter.geoserver_password.arn}"]
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

resource "aws_iam_role_policy" "cloudwatch_attach" {
  name   = "${module.label_geoserver.name}-cloudwatch"
  role   = "${aws_iam_role.geosrv_exec.name}"
  policy = "${data.aws_iam_policy_document.cloudwatch_policy.json}"
}

#######
# EFS #
#######
resource "aws_security_group" "geo_efs_sg" {
  name        = "${module.label.name}-efs-sg"
  description = "Allow NFS access from Geoweb ECS cluster"
  tags        = "${module.label.tags}"
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

resource "aws_efs_file_system" "geo_efs" {
  creation_token = "${module.label.name}-efs"
  tags           = "${module.label.tags}"
}

resource "aws_efs_mount_target" "geo_efs_mount" {
  count           = "${length(module.shared.private_subnets)}"
  file_system_id  = "${aws_efs_file_system.geo_efs.id}"
  subnet_id       = "${element(module.shared.private_subnets, count.index)}"
  security_groups = ["${aws_security_group.geo_efs_sg.id}"]
}
