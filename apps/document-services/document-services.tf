module "label" {
  source = "github.com/mitlibraries/tf-mod-name?ref=0.12"
  name   = "document-services"
}

resource "aws_security_group" "default" {
  description = "${module.label.name} Additional Security Groups"
  vpc_id      = module.shared.vpc_id
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

  tags = module.label.tags
}

# Create an S3 Bucket to store MIT cert and key, and attach to beanstalk instance profile for access
module "s3_cert_store" {
  source             = "github.com/mitlibraries/tf-mod-s3-iam?ref=0.12"
  name               = "document-services-certstore"
  versioning_enabled = "false"
}

resource "aws_iam_role_policy_attachment" "default_ro" {
  role       = module.eb_docsvcs.ec2_instance_profile_role_name
  policy_arn = module.s3_cert_store.readonly_arn
}

module "rds_docsvcs" {
  source                      = "github.com/mitlibraries/tf-mod-rds?ref=0.12"
  name                        = "docsvcs-rds"
  engine                      = var.rds_engine
  engine_version              = var.rds_maj_eng_ver
  instance_class              = var.rds_inst_class
  allocated_storage           = var.rds_storage
  database_name               = var.rds_db_name
  database_user               = var.rds_username
  database_password           = var.rds_password
  database_port               = var.rds_port
  db_parameter_group          = var.rds_param_grp
  maintenance_window          = var.rds_maint_win
  backup_window               = var.rds_backup_win
  backup_retention_period     = var.rds_backup_retain
  vpc_id                      = module.shared.vpc_id
  subnet_ids                  = module.shared.private_subnets
  security_group_ids          = [module.eb_docsvcs.security_group_id]
  major_engine_version        = var.rds_eng_ver
  allow_major_version_upgrade = var.rds_maj_upgrade
  apply_immediately           = var.rds_apply_immediately
  dns_zone_id                 = module.shared.private_zoneid
}

module "eb_docsvcs" {
  source = "github.com/mitlibraries/tf-mod-elasticbeanstalk-env?ref=0.12.1"

  app     = module.shared.docsvcs_app_name
  keypair = var.ssh_keypair
  name    = "document-services"
  vpc_id  = module.shared.vpc_id

  # We use public_subnets here since it's a singleInstance that needs to be accessed publicly
  instance_subnets            = module.shared.public_subnets
  security_groups             = [aws_security_group.default.id]
  instance_type               = var.eb_instance_class
  associate_public_ip_address = "true"
  environment_type            = "SingleInstance"
  rolling_update_enabled      = "false"
  rolling_update_type         = "Time"
  updating_min_in_service     = "0"
  solution_stack_name         = var.eb_solution_stack
  zone_id                     = module.shared.public_zoneid
  ssh_source_restriction      = var.ssh_subnet_restriction
  enable_managed_actions      = "false"
  autoscale_min               = "1"
  autoscale_max               = "1"

  # PHP variables
  document_root = "/"

  # Environment Variables
  # BUCKET_ID and *_S3 Variables are used for TLS config and are deployed via .ebxtensions in the app
  env_vars = "${
    map(
      "RDS_HOSTNAME", "${join(",", module.rds_docsvcs.hostname)}",
      "RDS_USERNAME", var.rds_username,
      "RDS_PASSWORD", var.rds_password,
      "RDS_DB_NAME", var.rds_db_name,
      "ENVIRONMENT", terraform.workspace,
      "BUCKET_ID", module.s3_cert_store.bucket_id,
      "INCOMMON_S3", "https://${module.s3_cert_store.bucket_domain_name}/InCommonChain.crt",
      "CERT_S3", "https://${module.s3_cert_store.bucket_domain_name}/${module.label.name}.mit.edu.crt",
      "KEY_S3", "https://${module.s3_cert_store.bucket_domain_name}/${module.label.name}.mit.edu.key",
      "CYBERSOURCE_ACCESS_KEY", var.cybersource_access_key,
      "CYBERSOURCE_PROFILE_ID", var.cybersource_profile_id,
      "MAIL_HOST", var.mail_host,
      "MAIL_PASSWORD", var.mail_password,
      "MAIL_PORT", var.mail_port,
      "MAIL_USERNAME", var.mail_username
    )
  }"
}
