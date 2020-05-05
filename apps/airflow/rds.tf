resource "aws_db_instance" "default" {
  identifier                  = module.label.name
  engine                      = "postgres"
  engine_version              = "11.1"
  allocated_storage           = 10
  storage_type                = "gp2"
  instance_class              = var.postgres_instance_type
  name                        = "airflow"
  username                    = var.postgres_username
  password                    = var.postgres_password
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
  description = "Airflow DB subnet group"
  subnet_ids  = module.shared.private_subnets
  tags        = module.label.tags
}

resource "aws_db_parameter_group" "default" {
  name   = module.label.name
  family = "postgres11"
  tags   = module.label.tags
}

resource "aws_security_group" "rds" {
  name        = "${module.label.name}-rds"
  description = "Airflow RDS security group"
  tags        = module.label.tags
  vpc_id      = module.shared.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [
      aws_security_group.airflow.id,
      module.shared.bastion_ingress_sgid,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
