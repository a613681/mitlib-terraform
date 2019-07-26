module "label" {
  source = "git::https://github.com/MITLibraries/tf-mod-name?ref=master"
  name   = "${var.name}"
}

data "aws_ami" "default" {
  most_recent = true
  owners      = ["379101102735"]

  filter {
    name   = "name"
    values = ["debian-stretch-hvm-x86_64-gp2-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "template_file" "default" {
  template = "${file("${path.module}/userdata.tpl")}"

  vars = {
    efs_dns   = "${aws_efs_file_system.default.dns_name}"
    efs_mount = "${var.mount}"
  }
}

resource "aws_instance" "default" {
  instance_type = "t3.small"

  vpc_security_group_ids = ["${var.security_groups}"]

  ami       = "${data.aws_ami.default.id}"
  key_name  = "${var.key_name}"
  subnet_id = "${var.subnet}"
  tags      = "${module.label.tags}"
  user_data = "${data.template_file.default.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "default" {
  zone_id = "${var.zone}"
  name    = "${module.label.name}.mitlib.net"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_instance.default.private_dns}"]
}

resource "aws_efs_file_system" "default" {
  creation_token = "${module.label.name}-efs"
  tags           = "${module.label.tags}"
}

resource "aws_efs_mount_target" "default" {
  file_system_id  = "${aws_efs_file_system.default.id}"
  subnet_id       = "${var.subnet}"
  security_groups = ["${aws_security_group.default.id}"]
}

resource "aws_security_group" "default" {
  name        = "${module.label.name}-efs"
  description = "NFS security group"
  tags        = "${module.label.tags}"
  vpc_id      = "${var.vpc}"

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = ["${var.security_groups}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
