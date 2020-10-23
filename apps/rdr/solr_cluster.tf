resource "null_resource" "solr_ansible_playbook" {
  triggers = {
    build_number = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i ansible/inventories/${terraform.workspace} ansible/solr_provision.yaml -e terraform_workspace=${terraform.workspace} -e app_name='rdr' | tee -a solr_provision.log"
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

resource "aws_route53_record" "solr_dv" {
  zone_id = module.shared.private_zoneid
  name    = "${module.label.name}-solr.mitlib.net"
  type    = "CNAME"
  ttl     = "300"
  records = [lookup(local.shared_alb_dns, local.env)]
}

resource "aws_lb_listener_rule" "solr_default" {
  listener_arn = lookup(local.shared_alb_listeners, local.env)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.solr_default.arn
  }

  condition {
    field = "host-header"
    values = [
      aws_route53_record.solr_dv.fqdn
    ]
  }
}

resource "aws_lb_target_group" "solr_default" {
  name        = "${module.label.name}-solr"
  port        = 8983
  protocol    = "HTTP"
  vpc_id      = module.shared.vpc_id
  target_type = "ip"

  deregistration_delay = "15"

  health_check {
    path    = "/solr/collection1/admin/ping"
    matcher = "200-399"
    port    = 8983
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "solr_default" {
  count            = var.solr_instance_count
  target_group_arn = aws_lb_target_group.solr_default.arn
  target_id        = element(aws_instance.solr_cluster.*.private_ip, count.index)
  port             = 8983
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
  user_data                   = data.template_cloudinit_config.solr_config.rendered
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
    from_port       = 8983
    to_port         = 8983
    protocol        = "tcp"
    security_groups = ["${lookup(local.shared_alb_sgids, local.env)}"]
  }

  ingress {
    from_port = 8983
    to_port   = 8983
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port       = 8983
    to_port         = 8983
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
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

data "template_file" "solr_pub_keys" {
  template = file("${path.module}/files/pub_keys.sh")
  vars = {
    s3_bucket_pubkeys = var.s3_bucket_pubkeys
    s3_bucket_uri     = var.s3_bucket_pubkeys_uri
    ssh_user          = var.ssh_user
  }
}

# user_data cloud init scripts
data "template_cloudinit_config" "solr_config" {
  gzip          = true
  base64_encode = true
  # Main cloud-config configuration file.
  part {
    filename     = "pub_keys.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.solr_pub_keys.rendered
  }
}
