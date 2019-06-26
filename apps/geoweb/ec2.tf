module "label_geoserver" {
  source = "git::https://github.com/MITLibraries/tf-mod-name?ref=master"
  name   = "geoserver"
}

module "label_solr" {
  source = "git::https://github.com/MITLibraries/tf-mod-name?ref=master"
  name   = "solr"
}

locals {
  geoserver_mount = "/mnt/geoserver"
  solr_mount      = "/mnt/solr"
}

resource "aws_security_group" "geoserver" {
  name   = "${module.label_geoserver.name}"
  vpc_id = "${module.shared.vpc_id}"
  tags   = "${module.label_geoserver.tags}"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["172.0.1.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "solr" {
  name   = "${module.label_solr.name}"
  vpc_id = "${module.shared.vpc_id}"
  tags   = "${module.label_solr.tags}"

  ingress {
    from_port   = 8983
    to_port     = 8983
    protocol    = "tcp"
    cidr_blocks = ["172.0.1.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
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

data "template_file" "geoserver" {
  template = "${file("${path.module}/userdata.tpl")}"

  vars = {
    efs_dns   = "${aws_efs_file_system.geoserver.dns_name}"
    efs_mount = "${local.geoserver_mount}"
  }
}

data "template_file" "solr" {
  template = "${file("${path.module}/userdata.tpl")}"

  vars = {
    efs_dns   = "${aws_efs_file_system.solr.dns_name}"
    efs_mount = "${local.solr_mount}"
  }
}

resource "aws_instance" "geoserver" {
  instance_type = "t3.small"

  vpc_security_group_ids = ["${module.shared.bastion_ingress_sgid}",
    "${aws_security_group.geoserver.id}",
  ]

  ami       = "${data.aws_ami.default.id}"
  key_name  = "mit-mgraves"
  subnet_id = "${module.shared.private_subnets[0]}"
  tags      = "${module.label_geoserver.tags}"
  user_data = "${data.template_file.geoserver.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "solr" {
  instance_type = "t3.small"

  vpc_security_group_ids = ["${module.shared.bastion_ingress_sgid}",
    "${aws_security_group.solr.id}",
  ]

  ami       = "${data.aws_ami.default.id}"
  key_name  = "mit-mgraves"
  subnet_id = "${module.shared.private_subnets[0]}"
  tags      = "${module.label_solr.tags}"
  user_data = "${data.template_file.solr.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "geoserver_dns" {
  zone_id = "${module.shared.private_zoneid}"
  name    = "${module.label_geoserver.name}.mitlib.net"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_instance.geoserver.private_dns}"]
}

resource "aws_route53_record" "solr_dns" {
  zone_id = "${module.shared.private_zoneid}"
  name    = "${module.label_solr.name}.mitlib.net"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_instance.solr.private_dns}"]
}

#########
## EFS ##
#########

resource "aws_efs_file_system" "geoserver" {
  creation_token = "${module.label_geoserver.name}-efs"
  tags           = "${module.label_geoserver.tags}"
}

resource "aws_efs_mount_target" "geoserver" {
  file_system_id  = "${aws_efs_file_system.geoserver.id}"
  subnet_id       = "${module.shared.private_subnets[0]}"
  security_groups = ["${aws_security_group.geoserver_efs.id}"]
}

resource "aws_security_group" "geoserver_efs" {
  name        = "${module.label_geoserver.name}-efs"
  description = "NFS security group"
  tags        = "${module.label_geoserver.tags}"
  vpc_id      = "${module.shared.vpc_id}"

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = ["${aws_security_group.geoserver.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_efs_file_system" "solr" {
  creation_token = "${module.label_solr.name}-efs"
  tags           = "${module.label_solr.tags}"
}

resource "aws_efs_mount_target" "solr" {
  file_system_id  = "${aws_efs_file_system.solr.id}"
  subnet_id       = "${module.shared.private_subnets[0]}"
  security_groups = ["${aws_security_group.solr_efs.id}"]
}

resource "aws_security_group" "solr_efs" {
  name        = "${module.label_solr.name}-efs"
  description = "NFS security group"
  tags        = "${module.label_solr.tags}"
  vpc_id      = "${module.shared.vpc_id}"

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = ["${aws_security_group.solr.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
