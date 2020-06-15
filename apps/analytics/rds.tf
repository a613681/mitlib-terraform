##==-- RDS Instance --==##
resource "aws_db_instance" "default" {
  identifier                  = module.label.name
  engine                      = "mysql"
  engine_version              = "5.7.19"
  allocated_storage           = var.db_storage_size
  storage_type                = "gp2"
  storage_encrypted           = true
  kms_key_id                  = var.rds_kms_key_id
  instance_class              = var.db_instance_type
  name                        = "analytics"
  username                    = var.mysql_user
  password                    = var.mysql_password
  db_subnet_group_name        = aws_db_subnet_group.default.name
  vpc_security_group_ids      = [aws_security_group.rds.id]
  allow_major_version_upgrade = false
  parameter_group_name        = aws_db_parameter_group.default.name
  backup_retention_period     = 30
  backup_window               = "03:00-04:00"
  maintenance_window          = "Mon:04:00-Mon:05:00"
  apply_immediately           = true
  final_snapshot_identifier   = false
  skip_final_snapshot         = false
  tags                        = module.label.tags
}

resource "aws_db_subnet_group" "default" {
  name        = module.label.name
  description = "DB subnet group"
  subnet_ids  = module.shared.private_subnets
  tags        = module.label.tags
}

resource "aws_db_parameter_group" "default" {
  name   = module.label.name
  tags   = module.label.tags
  family = "mysql5.7"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

resource "aws_security_group" "rds" {
  name        = "${module.label.name}-rds"
  description = "Analytics RDS security group"
  tags        = module.label.tags
  vpc_id      = module.shared.vpc_id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    security_groups = [
      module.shared.bastion_ingress_sgid,
      aws_security_group.default.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
