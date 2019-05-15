module "label" {
  source = "git::https://github.com/MITLibraries/tf-mod-name?ref=master"
  name   = "libraries-website"
}

resource "aws_security_group" "default" {
  name        = "${module.label.name}-sg"
  description = "${module.label.name} ec2 security group"
  tags        = "${module.label.tags}"

  # Create this security group in the MIT VPC
  vpc_id = "vpc-0ef9d327814ed449d"

  # Limit SSH to 18/9
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
    cidr_blocks = ["18.0.0.0/9", "10.0.0.0/8"]
  }

  # Open Port 443 web
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["18.0.0.0/9", "10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "db" {
  source             = "git::https://github.com/mitlibraries/tf-mod-rds?ref=master"
  engine             = "mariadb"
  engine_version     = "10.3.8"
  instance_class     = "db.t2.micro"
  allocated_storage  = 20
  name               = "${module.label.name}-rds"
  database_name      = "mitwordpress"
  database_user      = "${var.rds_username}"
  database_password  = "${var.rds_password}"
  database_port      = "3306"
  db_parameter_group = "mariadb10.3"
  maintenance_window = "Sun:00:00-Sun:03:00"
  backup_window      = "03:00-06:00"

  # Create this RDS instance in the MIT VPC
  vpc_id = "vpc-0ef9d327814ed449d"

  # Use the two private subnets in the MIT VPC
  subnet_ids                  = ["subnet-0e7fc7820ca9a9474", "subnet-057ad698467b9c692"]
  security_group_ids          = ["${aws_security_group.default.id}"]
  major_engine_version        = "10.3"
  allow_major_version_upgrade = "false"
  apply_immediately           = "true"
  dns_zone_id                 = "${module.shared.private_zoneid}"
}

resource "aws_instance" "default" {
  instance_type = "t3.small"
  ami           = "ami-011b3ccf1bd6db744"

  # Use the public MIT 18net subnet for this host's "private" ip
  subnet_id                   = "subnet-0744a5c9beeb49a20"
  vpc_security_group_ids      = ["${aws_security_group.default.id}"]
  ebs_optimized               = "true"
  key_name                    = "vab-aws"
  associate_public_ip_address = "false"
  tags                        = "${module.label.tags}"

  # The current Document Root is around 30G. 50G allocated for growth.
  root_block_device {
    volume_type = "standard"
    volume_size = "50"
  }
}

resource "aws_route53_record" "libraries-website" {
  name    = "${module.label.name}"
  zone_id = "${var.dns_zone_id}"
  type    = "A"
  ttl     = "300"

  # Pointed at the 18net IP address.
  records = ["${aws_instance.default.*.private_ip}"]
  count   = "${var.enabled == "true" ? 1 : 0}"

  # The mitlib.net zone
  zone_id = "Z226BWKODTCHOZ"
}
