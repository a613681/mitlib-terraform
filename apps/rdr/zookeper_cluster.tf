resource "null_resource" "zk_ansible_playbook" {
  triggers = {
    build_number = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i ansible/inventories/${terraform.workspace} ansible/zookeeper_provision.yaml -e terraform_workspace=${terraform.workspace} -e app_name='rdr' | tee -a zookeeper_provision.log"
  }
  depends_on = [
    aws_route53_record.zookeeper,
  ]
}

resource "aws_route53_record" "zookeeper" {
  count   = var.zookeeper_instance_count
  zone_id = module.shared.private_zoneid
  name    = "${module.label.name}-zookeeper-${count.index}"
  type    = "CNAME"
  ttl     = "300"
  records = [
    element(aws_instance.zookeeper_cluster.*.private_dns, count.index)
  ]
}

resource "aws_instance" "zookeeper_cluster" {
  count                       = var.zookeeper_instance_count
  instance_type               = var.zookeeper_instance_type
  ami                         = var.ami
  ebs_optimized               = true
  associate_public_ip_address = false
  key_name                    = var.key_name
  subnet_id                   = element(module.shared.private_subnets, 2)
  vpc_security_group_ids      = [aws_security_group.zookeeper_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.get_pubkey_profile.name
  user_data                   = data.template_cloudinit_config.zk_config.rendered
  tags = {
    "Name" = "${module.label.name}-zookeeper-${count.index}"
  }
  root_block_device {
    volume_type = var.volume_type
    volume_size = var.volume_size
  }
}

resource "aws_security_group" "zookeeper_sg" {
  name        = "${module.label.name}-zookeeper-sg"
  description = "${module.label.name} zookeeper security group"
  vpc_id      = module.shared.vpc_id
  tags = {
    "Name" = "${module.label.name}-zookeeper-sg"
  }

  ingress {
    from_port = 2181
    to_port   = 2181
    protocol  = "tcp"
    self      = true
  }
  ingress {
    from_port = 2888
    to_port   = 2888
    protocol  = "tcp"
    self      = true
  }
  ingress {
    from_port = 3888
    to_port   = 3888
    protocol  = "tcp"
    self      = true
  }
  ingress {
    from_port       = 2181
    to_port         = 2181
    protocol        = "tcp"
    security_groups = [aws_security_group.solr_sg.id]
  }
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [module.shared.bastion_ingress_sgid]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "zk_pub_keys" {
  template = file("${path.module}/files/pub_keys.sh")
  vars = {
    s3_bucket_pubkeys = var.s3_bucket_pubkeys
    s3_bucket_uri     = var.s3_bucket_pubkeys_uri
    ssh_user          = var.ssh_user
  }
}

# user_data cloud init scripts
data "template_cloudinit_config" "zk_config" {
  gzip          = true
  base64_encode = true
  # Main cloud-config configuration file.
  part {
    filename     = "pub_keys.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.zk_pub_keys.rendered
  }
}
