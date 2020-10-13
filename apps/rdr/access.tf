module "label" {
  source = "github.com/mitlibraries/tf-mod-name?ref=0.12"
  name   = "rdr"
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

# IAM Role assigned to all RDR instances
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

# RDS
resource "aws_ssm_parameter" "rds_master_password" {
  name        = "${module.label.name}-rds-master-password"
  description = "SSM parameter RDS master password "
  type        = "SecureString"
  value       = var.rds_master_password
  tags = {
    "Name" = "${module.label.name}-rds-master-password"
  }
}

# Application
resource "aws_iam_role_policy" "app_ssm" {
  name   = "${module.label.name}-app-ssm"
  role   = aws_iam_role.role.name
  policy = data.aws_iam_policy_document.app_ssm.json
}

data "aws_iam_policy_document" "app_ssm" {
  statement {
    actions = ["ssm:GetParameters"]
    resources = [
      aws_ssm_parameter.rds_master_password.arn,
      aws_ssm_parameter.postgresql_database.arn,
      aws_ssm_parameter.postgresql_user.arn,
      aws_ssm_parameter.postgresql_password.arn,
      aws_ssm_parameter.postgresql_admin_password.arn
    ]
  }
}

resource "aws_ssm_parameter" "postgresql_password" {
  name        = "${module.label.name}-postgresql-password"
  description = "SSM parameter RDS dataverse password"
  type        = "SecureString"
  value       = var.postgresql_password
  tags = {
    "Name" = "${module.label.name}-postgresql_password"
  }
}

resource "aws_ssm_parameter" "postgresql_database" {
  name        = "${module.label.name}-postgresql-database"
  description = "SSM parameter RDS dataverse database"
  type        = "SecureString"
  value       = var.postgresql_database
  tags = {
    "Name" = "${module.label.name}-postgresql_password"
  }
}

resource "aws_ssm_parameter" "postgresql_user" {
  name        = "${module.label.name}-postgresql-user"
  description = "SSM parameter RDS dataverse user"
  type        = "SecureString"
  value       = var.postgresql_user
  tags = {
    "Name" = "${module.label.name}-postgresql_user"
  }
}

resource "aws_ssm_parameter" "postgresql_admin_password" {
  name        = "${module.label.name}-postgresql-admin-password"
  description = "SSM parameter RDS dataverse admin password "
  type        = "SecureString"
  value       = var.postgresql_admin_password
  tags = {
    "Name" = "${module.label.name}-postgresql-admin-password"
  }
}


# Efs Solr
resource "aws_iam_role_policy" "efs_solr_ssm" {
  name   = "${module.label.name}-efs-solr-ssm"
  role   = aws_iam_role.role.name
  policy = data.aws_iam_policy_document.efs_solr_ssm.json
}

data "aws_iam_policy_document" "efs_solr_ssm" {
  statement {
    actions = ["ssm:GetParameters"]
    resources = [
      aws_ssm_parameter.efs_solrs_mount.arn,
      aws_ssm_parameter.efs_solrs_dns.arn
    ]
  }
}

resource "aws_ssm_parameter" "efs_solrs_mount" {
  name        = "${module.label.name}-efs-solrs-mount"
  description = "SSM parameter efs solrs mount"
  type        = "SecureString"
  value       = var.efs_solrs_mount
  tags = {
    "Name" = "${module.label.name}-efs-solrs-mount"
  }
}

resource "aws_ssm_parameter" "efs_solrs_dns" {
  name        = "${module.label.name}-efs-solrs-dns"
  description = "SSM parameter RDR efs solrs dns "
  type        = "SecureString"
  value       = aws_efs_file_system.solrs_data_backup.dns_name
  tags = {
    "Name" = "${module.label.name}-efs-solrs-dns"
  }
}

# Efs Zookeeper
resource "aws_iam_role_policy" "efs_zookeepers_ssm" {
  name   = "${module.label.name}-efs-zookeepers-ssm"
  role   = aws_iam_role.role.name
  policy = data.aws_iam_policy_document.efs_zookeepers_ssm.json
}

data "aws_iam_policy_document" "efs_zookeepers_ssm" {
  statement {
    actions = ["ssm:GetParameters"]
    resources = [
      aws_ssm_parameter.efs_zookeepers_mount.arn,
      aws_ssm_parameter.efs_zookeepers_dns.arn
    ]
  }
}

resource "aws_ssm_parameter" "efs_zookeepers_mount" {
  name        = "${module.label.name}-efs-zookeepers-mount"
  description = "SSM parameter RDR efs zookeepers mount"
  type        = "SecureString"
  value       = var.efs_zookeepers_mount
  tags = {
    "Name" = "${module.label.name}-efs-zookeepers-mount"
  }
}

resource "aws_ssm_parameter" "efs_zookeepers_dns" {
  name        = "${module.label.name}-efs-zookeepers-dns"
  description = "SSM parameter RDR efs zookeepers dns "
  type        = "SecureString"
  value       = aws_efs_file_system.zookeepers_data_backup.dns_name
  tags = {
    "Name" = "${module.label.name}-efs-zookeepers-dns"
  }
}



####### Parameter store if we change and want to do different roles per instance, pub_keyes, efs and other #######
## Public keys parameter store vars, make available to all RDR instances
# data "aws_iam_policy_document" "ssm_pub_keys" {
#   statement {
#     actions = ["ssm:GetParameters"]
#     resources = [
#       aws_ssm_parameter.s3_bucket_pubkeys.arn,
#       aws_ssm_parameter.s3_bucket_uri.arn,
#       aws_ssm_parameter.ssh_user.arn
#     ]
#   }
# }

# data "template_file" "get_pubkey_policy" {
#   template = file("${path.module}/iam/get_pubkey_policy.json")
#   vars = {
#     s3_bucket_pubkeys = aws_ssm_parameter.s3_bucket_pubkeys
#   }
# }

# data "template_file" "assume_role_policy" {
#   template = file("${path.module}/iam/assume_role_policy.json")
# }

# resource "aws_ssm_parameter" "s3_bucket_pubkeys" {
#   name        = "${module.label.name}-s3-bucket-pubkeys"
#   description = "SSM parameter RDS s3 bucket pubkeys "
#   type        = "SecureString"
#   value       = var.s3_bucket_pubkeys
#   tags = {
#     "Name" = "${module.label.name}-s3-bucket-pubkeys"
#   }
# }

# resource "aws_ssm_parameter" "s3_bucket_uri" {
#   name        = "${module.label.name}-s3-bucket-uri"
#   description = "SSM parameter RDS s3 bucket uri"
#   type        = "SecureString"
#   value       = var.s3_bucket_uri
#   tags = {
#     "Name" = "${module.label.name}-s3-bucket-uri"
#   }
# }

# resource "aws_ssm_parameter" "ssh_user" {
#   name        = "${module.label.name}-ssh-user"
#   description = "SSM parameter RDS ssh user "
#   type        = "SecureString"
#   value       = var.ssh_user
#   tags = {
#     "Name" = "${module.label.name}-ssh-user"
#   }
# }

# ## Application role and parameter store values
# resource "aws_iam_role" "app_role" {
#   name               = "${module.label.name}-app-role"
#   description        = "IAM role assigned to Research Data Registry Application instances"
#   assume_role_policy = data.template_file.assume_role_policy.rendered
#   tags               = module.label.tags
# }

# resource "aws_iam_role_policy" "app_get_pubkey_policy" {
#   name   = "${module.label.name}-app-get-pubkey-policy"
#   role   = aws_iam_role.app_role.id
#   policy = data.template_file.get_pubkey_policy.rendered
# }

# resource "aws_iam_instance_profile" "app_get_pubkey_profile" {
#   name = "${module.label.name}-app-get-pubkey-profile"
#   role = aws_iam_role.app_role.name
# }

# resource "aws_iam_role_policy" "app_ssm" {
#   name   = "${module.label.name}-app-ssm"
#   role   = aws_iam_role.app_role.name
#   policy = data.aws_iam_policy_document.ssm_pub_keys.json
# }

# resource "aws_iam_role_policy" "app_rds_ssm" {
#   name   = "${module.label.name}-app-rds-ssm"
#   role   = aws_iam_role.app_role.name
#   policy = data.aws_iam_policy_document.rds_ssm.json
# }

# data "aws_iam_policy_document" "rds_ssm" {
#   statement {
#     actions = ["ssm:GetParameters"]
#     resources = [
#       aws_ssm_parameter.rds_master_password.arn,
#       aws_ssm_parameter.postgresql_password.arn,
#       aws_ssm_parameter.postgresql_admin_password.arn
#     ]
#   }
# }

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
# ### solr 

# resource "aws_iam_role" "solr_role" {
#   name               = "${module.label.name}-solr-role"
#   description        = "IAM role assigned to Research Data Registry Solr instances"
#   assume_role_policy = data.template_file.assume_role_policy.rendered
#   tags               = module.label.tags
# }

# resource "aws_iam_role_policy" "solr_get_pubkey_policy" {
#   name   = "${module.label.name}-solr-get-pubkey-policy"
#   role   = aws_iam_role.solr_role.id
#   policy = data.template_file.get_pubkey_policy.rendered
# }

# resource "aws_iam_instance_profile" "solr_get_pubkey_profile" {
#   name = "${module.label.name}-solr-get-pubkey-profile"
#   role = aws_iam_role.solr_role.name
# }

# resource "aws_iam_role_policy" "solr_ssm_pub_keys" {
#   name   = "${module.label.name}-solr-ssm-pub-keys"
#   role   = aws_iam_role.solr_role.name
#   policy = data.aws_iam_policy_document.ssm_pub_keys.json
# }

# resource "aws_iam_role_policy" "efs_solr_ssm" {
#   name   = "${module.label.name}-efs-solr-ssm"
#   role   = aws_iam_role.solr_role.name
#   policy = data.aws_iam_policy_document.efs_solr_ssm.json
# }

# data "aws_iam_policy_document" "efs_solr_ssm" {
#   statement {
#     actions = ["ssm:GetParameters"]
#     resources = [
#       aws_ssm_parameter.efs_solrs_mount.arn,
#       aws_ssm_parameter.efs_solrs_dns.arn
#     ]
#   }
# }

# resource "aws_ssm_parameter" "efs_solrs_mount" {
#   name        = "${module.label.name}-efs-solrs-mount"
#   description = "SSM parameter RDS master password "
#   type        = "SecureString"
#   value       = var.efs_solrs_mount
#   tags = {
#     "Name" = "${module.label.name}-efs-solrs-mount"
#   }
# }

# resource "aws_ssm_parameter" "efs_solrs_dns" {
#   name        = "${module.label.name}-efs-solrs-dns"
#   description = "SSM parameter RDS master password "
#   type        = "SecureString"
#   value       = aws_efs_file_system.solrs_data_backup.dns_name
#   tags = {
#     "Name" = "${module.label.name}-efs-solrs-dns"
#   }
# }
### zookeeper
# data "aws_iam_policy_document" "zookeeper_ssm" {
#   statement {
#     actions = ["ssm:GetParameters"]
#     resources = [
#       aws_ssm_parameter.rds_master_password.arn,
#       aws_ssm_parameter.postgresql_password.arn,
#       aws_ssm_parameter.postgresql_admin_password.arn
#     ]
#   }
# }
# 
###############################################


