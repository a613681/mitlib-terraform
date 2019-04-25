module "rds" {
  source                      = "git::https://github.com/mitlibraries/tf-mod-rds?ref=master"
  engine                      = "postgres"
  engine_version              = "11.1"
  instance_class              = "db.t3.small"
  allocated_storage           = 160
  storage_type                = "gp2"
  name                        = "geo-postgis"
  database_name               = "postgis"
  database_user               = "${var.postgis_username}"
  database_password           = "${var.postgis_password}"
  database_port               = "5432"
  db_parameter_group          = "postgres11"
  maintenance_window          = "Sun:00:00-Sun:03:00"
  backup_window               = "03:00-06:00"
  vpc_id                      = "${module.shared.vpc_id}"
  subnet_ids                  = ["${module.shared.private_subnets}"]
  security_group_ids          = ["${aws_security_group.ecs.id}", "${module.shared.bastion_ingress_sgid}"]
  major_engine_version        = "11"
  allow_major_version_upgrade = "false"
  apply_immediately           = "true"
  dns_zone_id                 = "${module.shared.private_zoneid}"
}
