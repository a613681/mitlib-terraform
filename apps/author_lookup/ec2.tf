module "label" {
  source = "github.com/mitlibraries/tf-mod-name?ref=0.12"
  name   = "author_lookup"
}

resource "aws_security_group" "default" {
  name        = "${module.label.name}-sg"
  description = "${module.label.name} ec2 security group"
  tags        = module.label.tags
  vpc_id      = var.vpc_id
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
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.get_pubkey_profile.name
  user_data                   = data.template_file.user_data.rendered

  tags = module.label.tags
  root_block_device {
    volume_type = var.volume_type
    volume_size = var.volume_size
  }

  provisioner "remote-exec" {
    inline = ["echo 'Hello World'> /home/ubuntu/a.txt"]
    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.private_key_path)
      host        = aws_instance.default.private_ip
    }
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.default.private_ip}"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ansible/inventories/${terraform.workspace} ansible/provision.yaml | tee -a provision.log"
  }
}

resource "aws_route53_record" "author_lookup_private" {
  name    = module.label.name
  zone_id = module.shared.private_zoneid
  type    = "A"
  ttl     = "60"
  records = aws_instance.default.*.private_ip
}

resource "aws_route53_record" "author_lookup_public" {
  name    = module.label.name
  zone_id = module.shared.public_zoneid
  type    = "A"
  ttl     = "60"
  records = aws_instance.default.*.private_ip
}

resource "aws_iam_role" "role" {
  name               = "${module.label.name}_role"
  assume_role_policy = data.template_file.assume_role_policy.rendered
  tags               = module.label.tags
}

resource "aws_iam_role_policy" "get_pubkey_policy" {
  name   = "${module.label.name}-get_pubkey_policy"
  role   = aws_iam_role.role.id
  policy = data.template_file.get_pubkey_policy.rendered
}

resource "aws_iam_role_policy" "s3_deploy_policy" {
  name   = "${module.label.name}_s3_deploy_policy"
  role   = aws_iam_role.role.id
  policy = data.template_file.s3_deploy_policy.rendered
}

resource "aws_iam_role_policy" "read_secrets_policy" {
  name   = "${module.label.name}_read_secrets_policy"
  role   = aws_iam_role.role.id
  policy = data.template_file.read_secrets_policy.rendered
}

resource "aws_iam_instance_profile" "get_pubkey_profile" {
  name = "${module.label.name}_profile"
  role = aws_iam_role.role.name
}

data "template_file" "user_data" {
  template = file("${path.module}/files/user_data.sh")

  vars = {
    s3_bucket_pubkeys           = var.s3_bucket_pubkeys
    s3_bucket_uri               = var.s3_bucket_uri
    ssh_user                    = var.ssh_user
    additional_user_data_script = var.additional_user_data_script
  }
}

data "template_file" "get_pubkey_policy" {
  template = file("${path.module}/files/get_pubkey_policy.json")

  vars = {
    s3_bucket_pubkeys = var.s3_bucket_pubkeys
  }
}

data "template_file" "assume_role_policy" {
  template = file("${path.module}/files/assume_role_policy.json")
}

data "template_file" "read_secrets_policy" {
  template = file("${path.module}/files/read_secrets_policy.json")

}

data "template_file" "s3_deploy_policy" {
  template = file("${path.module}/files/s3_deploy_policy.json")

  vars = {
    s3_bucket_deploy = var.s3_bucket_deploy
  }
}
