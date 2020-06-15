resource "aws_efs_file_system" "default" {
  creation_token = module.label.name
  tags           = module.label.tags
  encrypted      = true
  kms_key_id     = var.efs_kms_key_id
}

resource "aws_efs_mount_target" "default" {
  file_system_id  = aws_efs_file_system.default.id
  count           = 2
  subnet_id       = module.shared.private_subnets[count.index]
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_access_point" "default" {
  file_system_id = aws_efs_file_system.default.id
}

resource "aws_security_group" "efs" {
  name        = "${module.label.name}-efs"
  description = "EFS security group"
  tags        = module.label.tags
  vpc_id      = module.shared.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.default.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
