resource "aws_efs_file_system" "solrs_data_backup" {
  creation_token = "${module.label.name}-efs-solrs-data-backup"
  tags = {
    "Name" = "${module.label.name}-efs-solrs-data-backup"
  }
}

resource "aws_efs_mount_target" "solrs_data_mount" {
  file_system_id  = aws_efs_file_system.solrs_data_backup.id
  subnet_id       = element(module.shared.private_subnets, 2)
  security_groups = [aws_security_group.efs_solrs_sg.id]
}

resource "aws_security_group" "efs_solrs_sg" {
  name        = "${module.label.name}-efs-solrs-sg"
  description = "RDR solrs data backup EFS security group"
  tags = {
    "Name" = "${module.label.name}-efs-solrs-sg"
  }
  vpc_id = module.shared.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.solr_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_efs_file_system" "zookeepers_data_backup" {
  creation_token = "${module.label.name}-efs-zookeepers-data-backup"
  tags = {
    "Name" = "${module.label.name}-efs-zookeepers-data-backup"
  }
}

resource "aws_efs_mount_target" "zookeepers_data_mount" {
  file_system_id  = aws_efs_file_system.zookeepers_data_backup.id
  subnet_id       = element(module.shared.private_subnets, 2)
  security_groups = [aws_security_group.efs_zookeepers_sg.id]
}

resource "aws_security_group" "efs_zookeepers_sg" {
  name        = "${module.label.name}-efs-zookeepers-sg"
  description = "RDR Zookeepers data backup EFS security group"
  tags = {
    "Name" = "${module.label.name}-efs-zookeepers-sg"
  }
  vpc_id = module.shared.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.zookeeper_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
