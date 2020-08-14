resource "null_resource" "solr_ansible_playbook" {
  triggers = {
    build_number = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i ansible/inventories/${terraform.workspace} ansible/solr_provision.yaml | tee -a solr_provision.log"
  }
  depends_on = [
    aws_route53_record.solr,
  ]
}

resource "aws_route53_record" "solr" {
  count   = var.solr_instance_count
  zone_id = module.shared.private_zoneid
  name    = "${module.label.name}-solr-${count.index}"
  type    = "CNAME"
  ttl     = "300"
  records = [
    element(aws_instance.solr_cluster.*.private_dns, count.index)
  ]
}

resource "aws_instance" "solr_cluster" {
  count                       = var.solr_instance_count
  instance_type               = var.solr_instance_type
  ami                         = var.ami
  ebs_optimized               = true
  associate_public_ip_address = false
  key_name                    = var.key_name
  subnet_id                   = element(module.shared.private_subnets, 2)
  vpc_security_group_ids      = [aws_security_group.solr_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.get_pubkey_profile.name
  user_data                   = data.template_file.solr_user_data.rendered
  tags = {
    "Name" = "${module.label.name}-solr-${count.index}"
  }
  root_block_device {
    volume_type = var.volume_type
    volume_size = var.volume_size
  }
}

resource "aws_security_group" "solr_sg" {
  name        = "${module.label.name}-solr-sg"
  description = "${module.label.name} solr security group"
  vpc_id      = module.shared.vpc_id
  tags = {
    "Name" = "${module.label.name}-solr-sg"
  }

  ingress {
    from_port = 8983
    to_port   = 8983
    protocol  = "tcp"
    self      = true
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

data "template_file" "solr_user_data" {
  template = file("${path.module}/files/user_data.sh")
  vars = {
    s3_bucket_pubkeys = var.s3_bucket_pubkeys
    s3_bucket_uri     = var.s3_bucket_pubkeys_uri
    ssh_user          = var.ssh_user
  }
}
