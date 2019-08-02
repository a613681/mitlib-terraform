module "label" {
  source = "git::https://github.com/MITLibraries/tf-mod-name?ref=master"
  name   = "dome"
}

resource "aws_security_group" "default" {
  name        = "${module.label.name}-sg"
  description = "${module.label.name} ec2 security group"
  tags        = "${module.label.tags}"
  vpc_id      = "${module.shared.vpc_id}"

  # Limit SSH to MITNet
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["18.0.0.0/9", "10.0.0.0/8"]
  }

  # Open Port 80 web
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Open Port 443 web
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Open Port 2641 - handle.net Handle server resolver
  ingress {
    from_port   = 2641
    to_port     = 2641
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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
  instance_type = "t2.medium"
  ami           = "ami-011b3ccf1bd6db744"
  subnet_id     = "${var.subnet}"

  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  key_name               = "vab-aws"
  user_data              = "${data.template_file.default.rendered}"
  tags                   = "${module.label.tags}"

  root_block_device {
    volume_type = "standard"
    volume_size = "30"
  }
}

resource "aws_eip" "default" {
  instance = "${aws_instance.default.id}"
  vpc      = true
}

resource "aws_efs_file_system" "default" {
  creation_token = "${module.label.name}-efs"
  tags           = "${module.label.tags}"
}

resource "aws_efs_mount_target" "default" {
  file_system_id  = "${aws_efs_file_system.default.id}"
  subnet_id       = "${var.efs_subnet}"
  security_groups = ["${aws_security_group.efs.id}"]
}

resource "aws_security_group" "efs" {
  name        = "${module.label.name}-efs"
  description = "EFS security group"
  tags        = "${module.label.tags}"
  vpc_id      = "${module.shared.vpc_id}"

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = ["${aws_security_group.default.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route53_record" "dome" {
  name    = "${module.label.name}"
  zone_id = "${var.dns_zone_id}"
  type    = "A"
  ttl     = "300"

  records = ["${aws_eip.default.public_ip}"]
  count   = "${var.enabled == "true" ? 1 : 0}"
}
