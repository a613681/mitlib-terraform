module "label" {
  source = "github.com/mitlibraries/tf-mod-name?ref=0.12"
  name   = "archivematica"
}

# Security Group for the ec2 instance
resource "aws_security_group" "default" {
  name        = "${module.label.name}-sg"
  description = "${module.label.name} ec2 security group"
  tags        = module.label.tags
  vpc_id      = module.shared.vpc_id

  # Port 22 SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.sec_ssh_access_subnets
  }

  # Port 80 web UI
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.sec_web_access_subnets
  }

  # Port 443 web UI
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.sec_web_access_subnets
  }

  # Port 8000 Archivematica Storage Service web UI
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = var.sec_ss_access_subnets
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# The ec2 Instance
# This ec2 host will be used to run a webserver, database, and cache server
# to power the Archivematica product.
resource "aws_instance" "default" {
  instance_type = var.ec2_inst_type
  ami           = var.ec2_ami

  subnet_id              = var.ec2_subnet
  vpc_security_group_ids = [aws_security_group.default.id]
  key_name               = var.ec2_key_name
  tags                   = module.label.tags

  root_block_device {
    volume_type = var.ec2_vol_type
    volume_size = var.ec2_vol_size
  }
}

# An elastic IP for the ec2 instance
resource "aws_eip" "default" {
  instance = aws_instance.default.id
  vpc      = true
}

# DNS Record for the ec2 Host
resource "aws_route53_record" "default" {
  name    = module.label.name
  zone_id = var.r53_dns_zone_id
  type    = "A"
  ttl     = "300"

  records = [aws_eip.default.public_ip]
  count   = var.r53_enabled == "true" ? 1 : 0
}
