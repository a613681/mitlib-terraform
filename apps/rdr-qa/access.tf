module "label" {
  source = "github.com/mitlibraries/tf-mod-name?ref=0.12"
  name   = "rdr-qa"
}

locals {
  env = terraform.workspace

  shared_alb_dns = {
    "stage" = "${module.shared.alb_restricted_dnsname}"
    "prod"  = "${module.shared.alb_public_dnsname}"
  }

  shared_alb_listeners = {
    "stage" = "${module.shared.alb_restricted_https_listener_arn}"
    "prod"  = "${module.shared.alb_public_https_listener_arn}"
  }

  shared_alb_sgids = {
    "stage" = "${module.shared.alb_restricted_sgid}"
    "prod"  = "${module.shared.alb_public_sgid}"
  }
}

resource "aws_iam_role" "role" {
  name               = "${module.label.name}-ec2"
  description        = "IAM role assigned to Research Data Registry EC2 instances"
  assume_role_policy = data.template_file.assume_role_policy.rendered
  tags               = module.label.tags
}

resource "aws_iam_role_policy" "get_pubkey_policy" {
  name   = "${module.label.name}-ec2-get-pubkey-policy"
  role   = aws_iam_role.role.id
  policy = data.template_file.get_pubkey_policy.rendered
}

resource "aws_iam_instance_profile" "get_pubkey_profile" {
  name = "${module.label.name}-ec2-profile"
  role = aws_iam_role.role.name
}

data "template_file" "get_pubkey_policy" {
  template = file("${path.module}/iam/get_pubkey_policy.json")

  vars = {
    s3_bucket_pubkeys = var.s3_bucket_pubkeys
  }
}

data "template_file" "assume_role_policy" {
  template = file("${path.module}/iam/assume_role_policy.json")
}

# resource "aws_ssm_parameter" "rds_master_password" {
#   name        = "${module.label.name}-rds-master-password"
#   description = "SSM parameter RDS master password "
#   type        = "SecureString"
#   value       = var.rds_master_password
#   tags = {
#     "Name" = "${module.label.name}-rds-master-password"
#   }
# }

# resource "aws_ssm_parameter" "postgresql_password" {
#   name        = "${module.label.name}-postgresql-password"
#   description = "SSM parameter RDS master password "
#   type        = "SecureString"
#   value       = var.postgresql_password
#   tags = {
#     "Name" = "${module.label.name}-postgresql_password"
#   }
# }

# resource "aws_ssm_parameter" "postgresql_admin_password" {
#   name        = "${module.label.name}-postgresql-admin-password"
#   description = "SSM parameter RDS master password "
#   type        = "SecureString"
#   value       = var.postgresql_admin_password
#   tags = {
#     "Name" = "${module.label.name}-postgresql-admin-password"
#   }
# }
# resource "aws_iam_role_policy" "ssm" {
#   name   = "${module.label.name}-ssm"
#   role   = aws_iam_role.role.name
#   policy = data.aws_iam_policy_document.ssm.json
# }

# data "aws_iam_policy_document" "ssm" {
#   statement {
#     actions = ["ssm:GetParameters"]
#     resources = [
#       aws_ssm_parameter.rds_master_password.arn,
#       aws_ssm_parameter.postgresql_password.arn,
#       aws_ssm_parameter.postgresql_admin_password.arn
#     ]
#   }
# }
