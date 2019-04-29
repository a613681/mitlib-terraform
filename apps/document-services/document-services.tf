module "label" {
  source = "git::https://github.com/mitlibraries/tf-mod-name?ref=master"
  name   = "document-services"
}

resource "aws_security_group" "default" {
  description = "${module.label.name} Additional Security Groups"
  vpc_id      = "${module.shared.vpc_id}"
  name        = "${module.label.name}-additional"

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

  tags = "${module.label.tags}"
}

# Create an S3 Bucket to store MIT cert and key, and attach to beanstalk instance profile for access

module "s3_cert_store" {
  source             = "git::https://github.com/mitlibraries/tf-mod-s3-iam?ref=master"
  name               = "document-services-certstore"
  versioning_enabled = "false"
}

resource "aws_iam_role_policy_attachment" "default_ro" {
  role       = "${module.eb_docsvcs.ec2_instance_profile_role_name}"
  policy_arn = "${module.s3_cert_store.readonly_arn}"
}

module "rds_docsvcs" {
  source                      = "git::https://github.com/mitlibraries/tf-mod-rds?ref=master"
  engine                      = "mysql"
  engine_version              = "5.5.61"
  instance_class              = "db.t3.micro"
  allocated_storage           = 20
  name                        = "docsvcs-rds"
  database_name               = "docsvcs"
  database_user               = "${var.rds_username}"
  database_password           = "${var.rds_password}"
  database_port               = "3306"
  db_parameter_group          = "mysql5.5"
  maintenance_window          = "Sun:00:00-Sun:03:00"
  backup_window               = "03:00-06:00"
  vpc_id                      = "${module.shared.vpc_id}"
  subnet_ids                  = ["${module.shared.private_subnets}"]
  security_group_ids          = ["${module.eb_docsvcs.security_group_id}"]
  major_engine_version        = "5.5"
  allow_major_version_upgrade = "false"
  apply_immediately           = "true"
  dns_zone_id                 = "${module.shared.private_zoneid}"
}

module "eb_docsvcs" {
  source = "git::https://github.com/mitlibraries/tf-mod-elasticbeanstalk-env?ref=master"

  app     = "${module.shared.docsvcs_app_name}"
  keypair = "mit-dornera"
  name    = "document-services"
  vpc_id  = "${module.shared.vpc_id}"

  # We use public_subnets here since it's a singleInstance that needs to be accessed publicly
  instance_subnets            = ["${module.shared.public_subnets}"]
  security_groups             = ["${aws_security_group.default.id}"]
  instance_type               = "t3.nano"
  associate_public_ip_address = "true"
  environment_type            = "SingleInstance"
  rolling_update_type         = "Time"
  updating_min_in_service     = "0"
  solution_stack_name         = "64bit Amazon Linux 2018.03 v2.8.8 running PHP 5.4"
  zone_id                     = "${module.shared.public_zoneid}"
  ssh_source_restriction      = "18.0.0.0/9"
  enable_managed_actions      = "false"
  autoscale_min               = "1"
  autoscale_max               = "1"

  # PHP variables
  document_root = "/"

  # Environment Variables
  # BUCKET_ID and *_S3 Variables are used for SSL config and are deployed via .ebxtensions in the app
  env_vars = "${
    map(
    "RDS_HOSTNAME",  "${join(",", module.rds_docsvcs.hostname)}",
    "RDS_USERNAME",  "${var.rds_username}",
    "RDS_PASSWORD",  "${var.rds_password}",
    "RDS_DB_NAME",   "docsvcs",
    "ENVIRONMENT", "${terraform.workspace}",
    "BUCKET_ID", "${module.s3_cert_store.bucket_id}",
    "INCOMMON_S3", "https://${module.s3_cert_store.bucket_domain_name}/InCommonChain.crt",
    "CERT_S3", "https://${module.s3_cert_store.bucket_domain_name}/${module.label.name}.mit.edu.crt",
    "KEY_S3", "https://${module.s3_cert_store.bucket_domain_name}/${module.label.name}.mit.edu.key"
    )
  }"
}
