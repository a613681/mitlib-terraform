module "rds" {
  source                  = "git::https://github.com/mitlibraries/tf-mod-rds?ref=master"
  engine                  = "postgres"
  engine_version          = "11.1"
  instance_class          = "${var.postgres_instance_type}"
  allocated_storage       = "${var.postgres_storage_size}"
  storage_type            = "gp2"
  name                    = "geo-postgis"
  database_name           = "${var.postgres_database}"
  database_user           = "${var.postgres_username}"
  database_password       = "${var.postgres_password}"
  database_port           = "5432"
  db_parameter_group      = "postgres11"
  maintenance_window      = "Sun:00:00-Sun:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = "${var.postgres_backup_retention}"
  vpc_id                  = "${module.shared.vpc_id}"
  subnet_ids              = ["${module.shared.private_subnets}"]

  security_group_ids = [
    "${module.shared.bastion_ingress_sgid}",
    "${aws_security_group.geoserver.id}",
    "${aws_security_group.geoblacklight.id}",
  ]

  major_engine_version        = "11"
  allow_major_version_upgrade = "false"
  apply_immediately           = "true"
  dns_zone_id                 = "${module.shared.private_zoneid}"
}
