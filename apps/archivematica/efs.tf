# EFS File system used for the Archivematica App processing folders.
resource "aws_efs_file_system" "default" {
  creation_token = "${module.label.name}-efs"
  tags           = module.label.tags
}

# A virtual NFS server to serve the EFS file system. We use an internal
# subnet from the VPC to prevent outside access.
resource "aws_efs_mount_target" "default" {
  file_system_id  = aws_efs_file_system.default.id
  subnet_id       = var.efs_subnet
  security_groups = [aws_security_group.efs.id]
}

# A security group for the EFS instance that limits access to port 2049 (NFS)
# to members of the EC2 instance security group. There is no need to access
# the EFS filesystem other than from the Archivematica application server.
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

# Here the EFS setup script (efs-setup.tpl) is loaded. The script sets up
# the EC2 host by installing the nfs-utils package and adding a mount into
# /etc/fstab for the EFS filesystem. It then does an initial mount of the
# EFS filesystem.
data "template_file" "default" {
  template = file("${path.module}/efs-setup.tpl")

  vars = {
    efs_dns   = aws_efs_file_system.default.dns_name
    efs_mount = var.efs_mount
  }
}
