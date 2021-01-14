module "label" {
  source = "github.com/mitlibraries/tf-mod-name?ref=0.12"
  name   = "isilon-mgmt"
}

resource "aws_security_group" "default" {
  name        = "${module.label.name}-sg"
  description = "${module.label.name} ec2 security group"
  tags        = module.label.tags

  # VPC to create this security group in
  vpc_id = var.vpc_id

  # Limit RDP access to MITNet or VPN
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = var.sec_access_subnets
  }

  # Limit SSH access to MITNet or VPN
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.sec_access_subnets
  }

  # Limit WinRM access to MITNet or VPN
  ingress {
    from_port   = 5985
    to_port     = 5985
    protocol    = "tcp"
    cidr_blocks = var.sec_access_subnets
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "default" {
  instance_type = var.ec2_inst_type
  ami           = var.ec2_ami

  # Use the public subnet for this host's "private" ip
  subnet_id                   = var.ec2_subnet
  vpc_security_group_ids      = [aws_security_group.default.id]
  ebs_optimized               = true
  key_name                    = var.ec2_key_name
  associate_public_ip_address = true
  tags                        = module.label.tags

  root_block_device {
    volume_type = var.ec2_vol_type
    volume_size = var.ec2_vol_size
  }
}

# Associate an Elastic IP for the Isilon Management VM
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.default.id
  allocation_id = var.eip
}