resource "aws_db_instance" "default" {
  identifier                  = module.label.name
  engine                      = "postgres"
  engine_version              = var.engine_version
  allocated_storage           = 30
  storage_type                = "gp2"
  storage_encrypted           = true
  kms_key_id                  = var.rds_kms_key_id
  instance_class              = var.rds_instance_type
  name                        = "rdr"
  username                    = var.rds_master_user
  password                    = var.rds_master_password
  db_subnet_group_name        = aws_db_subnet_group.default.name
  vpc_security_group_ids      = [aws_security_group.rds.id]
  allow_major_version_upgrade = false
  parameter_group_name        = aws_db_parameter_group.default.name
  backup_retention_period     = 30
  backup_window               = "03:00-04:00"
  maintenance_window          = "Mon:04:00-Mon:05:00"
  apply_immediately           = true
  tags                        = module.label.tags
}

resource "aws_db_subnet_group" "default" {
  name        = module.label.name
  description = "Dataverse RDR DB subnet group"
  subnet_ids  = module.shared.private_subnets
  tags        = module.label.tags
}

resource "aws_db_parameter_group" "default" {
  name   = module.label.name
  family = var.family
  tags   = module.label.tags
}

resource "aws_security_group" "rds" {
  name        = "${module.label.name}-rds-sg"
  description = "Dataverse RDR RDS security group"
  tags        = module.label.tags
  vpc_id      = module.shared.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [
      aws_security_group.app_sg.id,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route53_record" "rds" {
  zone_id = module.shared.private_zoneid
  name    = "${module.label.name}-rds.mitlib.net"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_db_instance.default.address]
}
