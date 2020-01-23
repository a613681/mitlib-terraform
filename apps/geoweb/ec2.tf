data "aws_security_group" "airflow" {
  name = "airflow-${local.env}-tasks"
}

resource "aws_security_group" "geoserver" {
  name        = "geoserver-${module.label.name}"
  description = "Security group associated with GeoServer instance."
  vpc_id      = "${module.shared.vpc_id}"
  tags        = "${module.label.tags}"

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = ["${aws_security_group.geoblacklight.id}"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${module.shared.bastion_ingress_sgid}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "solr" {
  name        = "solr-${module.label.name}"
  description = "Security group associated with Solr instance."
  vpc_id      = "${module.shared.vpc_id}"
  tags        = "${module.label.tags}"

  ingress {
    from_port = 8983
    to_port   = 8983
    protocol  = "tcp"
    security_groups = [
      "${aws_security_group.geoblacklight.id}",
      "${data.aws_security_group.airflow.id}",
    ]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${module.shared.bastion_ingress_sgid}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_iam_policy_document" "geoserver" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "geoserver_s3" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.slingshot_storage.arn}/*"]
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.slingshot_storage.arn}"]
  }
}

resource "aws_iam_role" "geoserver" {
  name               = "geoserver-${module.label.name}"
  tags               = "${module.label.tags}"
  description        = "IAM role for Geoserver EC2 instance."
  assume_role_policy = "${data.aws_iam_policy_document.geoserver.json}"
}

resource "aws_iam_role_policy" "geoserver_s3" {
  name   = "geoserver-s3-${module.label.name}"
  role   = "${aws_iam_role.geoserver.name}"
  policy = "${data.aws_iam_policy_document.geoserver_s3.json}"
}

resource "aws_iam_instance_profile" "geoserver" {
  name = "geoserver-${module.label.name}"
  role = "${aws_iam_role.geoserver.name}"
}

module "geoserver" {
  source           = "./modules/ec2"
  name             = "geoserver"
  vpc              = "${module.shared.vpc_id}"
  subnet           = "${module.shared.private_subnets[0]}"
  mount            = "/mnt/geoserver"
  security_groups  = ["${aws_security_group.geoserver.id}"]
  key_name         = "mit-mgraves"
  zone             = "${module.shared.private_zoneid}"
  instance_profile = "${aws_iam_instance_profile.geoserver.name}"
  instance_type    = "${var.instance_type}"
}

module "solr" {
  source          = "./modules/ec2"
  name            = "solr"
  vpc             = "${module.shared.vpc_id}"
  subnet          = "${module.shared.private_subnets[0]}"
  mount           = "/mnt/solr"
  security_groups = ["${aws_security_group.solr.id}"]
  key_name        = "mit-mgraves"
  zone            = "${module.shared.private_zoneid}"
  instance_type   = "${var.instance_type}"
}

#################
## EFS Backups ##
#################

data "aws_iam_policy_document" "backups" {
  statement {
    actions = ["sts:AssumeRole"]

    principals = {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "backups" {
  name               = "backups-${module.label.name}"
  tags               = "${module.label.tags}"
  description        = "IAM role for EFS backups"
  assume_role_policy = "${data.aws_iam_policy_document.backups.json}"
}

resource "aws_iam_role_policy_attachment" "backup_attach" {
  role       = "${aws_iam_role.backups.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "backup_restore" {
  role       = "${aws_iam_role.backups.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

resource "aws_backup_vault" "default" {
  name = "${module.label.name}"
  tags = "${module.label.tags}"
}

resource "aws_backup_plan" "default" {
  name = "${module.label.name}"
  tags = "${module.label.tags}"

  rule {
    rule_name         = "${module.label.name}"
    target_vault_name = "${aws_backup_vault.default.name}"
    schedule          = "cron(0 5 ? * * *)"

    lifecycle {
      delete_after = "${var.efs_backup_days}"
    }
  }
}

resource "aws_backup_selection" "default" {
  name         = "${module.label.name}"
  plan_id      = "${aws_backup_plan.default.id}"
  iam_role_arn = "${aws_iam_role.backups.arn}"

  resources = [
    "${module.geoserver.efs}",
    "${module.solr.efs}",
  ]
}
