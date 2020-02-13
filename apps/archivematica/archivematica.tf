module "label" {
  source = "github.com/mitlibraries/tf-mod-name?ref=0.12"
  name   = "archivematica"
}

# Security Group for the ec2 instance
# In staging, this security group should limit access to all systems to
# MIT and Artefactual. In production, this security group should limit
# access to SSH and the Storage Server (port 8000) to MIT and Artefactual
# and allow public access to web service (port 80 and port 443)
resource "aws_security_group" "default" {
  name        = "${module.label.name}-sg"
  description = "${module.label.name} ec2 security group"
  tags        = module.label.tags
  vpc_id      = module.shared.vpc_id

  # Limit SSH to MIT and vendor only
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.access_subnets
  }

  # Limit port 80 web to MIT and vendor only
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.access_subnets
  }

  # Limit port 443 web to MIT and vendor only
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.access_subnets
  }

  # Limit port 8000 Archivematica Storage Service web UI to MIT and vendor only
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = var.access_subnets
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
# to power the Archivematica product. The EBS OS disk is somewhat large
# because the database and cache data will be stored on it.
resource "aws_instance" "default" {
  # 2x8GB instance is required by the vendor
  instance_type = "t2.large"
  # Ubuntu 18.04 LTS x86-64
  ami = var.ec2_ami

  subnet_id              = var.ec2_subnet
  vpc_security_group_ids = [aws_security_group.default.id]
  key_name               = "vab-aws"
  tags                   = module.label.tags

  # OS disk limited to 30G since archival data will be stored on EFS
  root_block_device {
    volume_type = "standard"
    volume_size = "30"
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
  zone_id = var.dns_zone_id
  type    = "A"
  ttl     = "300"

  records = [aws_eip.default.public_ip]
  count   = var.enabled == "true" ? 1 : 0
}
