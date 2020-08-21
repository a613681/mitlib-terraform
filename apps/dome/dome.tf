module "label" {
  source = "github.com/mitlibraries/tf-mod-name?ref=0.12"
  name   = "dome"
}

resource "aws_security_group" "default" {
  name        = "${module.label.name}-sg"
  description = "${module.label.name} ec2 security group"
  tags        = module.label.tags
  vpc_id      = module.shared.vpc_id

  # Limit SSH to MITNet
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.sec_ssh_access_subnets
  }

  # Open Port 80 web
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.sec_web_access_subnets
  }

  # Open Port 443 web
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.sec_web_access_subnets
  }

  # Open Port 2641 - handle.net Handle server resolver
  ingress {
    from_port   = 2641
    to_port     = 2641
    protocol    = "tcp"
    cidr_blocks = var.sec_handle_access_subnets
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "default" {
  template = file("${path.module}/efs_script.tpl")

  vars = {
    efs_dns   = aws_efs_file_system.default.dns_name
    efs_mount = var.efs_mount
  }
}

resource "aws_instance" "default" {
  tags          = module.label.tags
  instance_type = var.ec2_inst_type
  ami           = var.ec2_ami
  subnet_id     = var.ec2_subnet

  vpc_security_group_ids = [aws_security_group.default.id]
  key_name               = var.ec2_key_name
  ebs_optimized          = true
  user_data              = data.template_file.default.rendered

  root_block_device {
    volume_size = var.ec2_vol_size
    volume_type = var.ec2_vol_type
  }
}

resource "aws_eip" "default" {
  instance = aws_instance.default.id
  vpc      = true
}

resource "aws_efs_file_system" "default" {
  creation_token = "${module.label.name}-efs"
  tags           = module.label.tags
}

resource "aws_efs_mount_target" "default" {
  file_system_id  = aws_efs_file_system.default.id
  subnet_id       = var.efs_subnet
  security_groups = [aws_security_group.efs.id]
}

resource "aws_security_group" "efs" {
  name        = "${module.label.name}-efs-sg"
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

resource "aws_route53_record" "default" {
  name    = module.label.name
  zone_id = var.r53_dns_zone_id
  type    = "A"
  ttl     = "300"

  records = [aws_eip.default.public_ip]
  count   = var.r53_enabled
}
