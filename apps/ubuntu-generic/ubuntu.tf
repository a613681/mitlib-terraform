module "label" {
  source = "github.com/mitlibraries/tf-mod-name?ref=0.12"
  name   = "ubuntu-generic"
}


resource "aws_security_group" "default" {
  name        = "${module.label.name}-sg"
  description = "${module.label.name} ec2 security group"
  tags        = module.label.tags

  # VPC to create this security group in
  vpc_id = var.vpc_id

  # Limit SSH to 18/11 and 10/8 (MITNet)
  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["18.0.0.0/11", "10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "default" {
  instance_type = var.instance_type
  ami           = var.ami

  # Use the public MIT 18net subnet for this host's "private" ip
  subnet_id                   = var.ec2_subnet
  vpc_security_group_ids      = [aws_security_group.default.id]
  ebs_optimized               = true
  key_name                    = var.key_name
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.get_pubkey_profile.name
  user_data                   = data.template_file.user_data.rendered
  tags                        = module.label.tags

  # The current Document Root is around 30G. 50G allocated for growth.
  root_block_device {
    volume_type = "standard"
    volume_size = var.volume_size
  }
}
resource "aws_iam_role" "get_pubkey_role" {
  name               = "${module.label.name}-get_pubkey_role"
  assume_role_policy = data.template_file.get_pubkey_assume_role_policy.rendered
  tags               = module.label.tags
}

resource "aws_iam_role_policy" "get_pubkey_policy" {
  name   = "${module.label.name}-get_pubkey_policy"
  role   = aws_iam_role.get_pubkey_role.id
  policy = data.template_file.get_pubkey_policy.rendered
}

resource "aws_iam_instance_profile" "get_pubkey_profile" {
  name = "${module.label.name}-get_pubkey_profile"
  role = aws_iam_role.get_pubkey_role.name
}


data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")

  vars = {
    s3_bucket_name              = var.s3_bucket_name
    s3_bucket_uri               = var.s3_bucket_uri
    ssh_user                    = var.ssh_user
    additional_user_data_script = var.additional_user_data_script
  }
}

data "template_file" "get_pubkey_policy" {
  template = file("${path.module}/get_pubkey_policy.json")

  vars = {
    s3_bucket_name = var.s3_bucket_name
  }
}

data "template_file" "get_pubkey_assume_role_policy" {
  template = file("${path.module}/get_pubkey_assume_role_policy.json")

  vars = {
    s3_bucket_name = var.s3_bucket_name
  }
}
