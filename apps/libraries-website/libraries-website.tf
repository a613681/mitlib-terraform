module "label" {
  source = "github.com/mitlibraries/tf-mod-name?ref=0.12"
  name   = "libraries-website"
}

resource "aws_security_group" "default" {
  name        = "${module.label.name}-sg"
  description = "${module.label.name} ec2 security group"
  tags        = module.label.tags

  # VPC to create this security group in
  vpc_id = var.vpc_id

  # Limit SSH to 18/11 and 10/8 (MITNet)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["18.0.0.0/11", "10.0.0.0/8"]
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "db" {
  source             = "github.com/mitlibraries/tf-mod-rds?ref=0.12"
  engine             = "mariadb"
  engine_version     = "10.3.8"
  instance_class     = "db.t2.micro"
  allocated_storage  = 20
  name               = "${module.label.name}-rds"
  database_name      = "mitwordpress"
  database_user      = var.rds_username
  database_password  = var.rds_password
  database_port      = "3306"
  db_parameter_group = "mariadb10.3"
  maintenance_window = "Sun:00:00-Sun:03:00"
  backup_window      = "03:00-06:00"

  # VPC to create this RDS db in
  vpc_id = var.vpc_id

  # Use the two private subnets in the MIT VPC
  subnet_ids                  = var.rds_subnets
  security_group_ids          = [aws_security_group.default.id]
  major_engine_version        = "10.3"
  allow_major_version_upgrade = "false"
  apply_immediately           = "true"
  dns_zone_id                 = module.shared.private_zoneid
}

resource "aws_instance" "default" {
  instance_type = "t3.small"
  ami           = "ami-011b3ccf1bd6db744"

  # Use the public MIT 18net subnet for this host's "private" ip
  subnet_id                   = var.ec2_subnet
  vpc_security_group_ids      = [aws_security_group.default.id]
  ebs_optimized               = "true"
  key_name                    = "vab-aws"
  associate_public_ip_address = "false"
  tags                        = module.label.tags

  # The current Document Root is around 30G. 50G allocated for growth.
  root_block_device {
    volume_type = "standard"
    volume_size = "50"
  }
}

resource "aws_efs_file_system" "default" {
  creation_token = "${module.label.name}-efs"
  tags           = module.label.tags
}

resource "aws_efs_mount_target" "default" {
  file_system_id  = aws_efs_file_system.default.id
  subnet_id       = var.efs_subnet
  security_groups = [aws_security_group.efs.id]
}

resource "aws_security_group" "efs" {
  name        = "${module.label.name}-efs"
  description = "EFS security group"
  tags        = module.label.tags
  vpc_id      = module.shared.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.default.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route53_record" "libraries-website" {
  name    = module.label.name
  zone_id = var.dns_zone_id
  type    = "A"
  ttl     = "300"

  # Pointed at the 18net IP address.
  records = aws_instance.default.*.private_ip
  count   = var.enabled == "true" ? 1 : 0
}

