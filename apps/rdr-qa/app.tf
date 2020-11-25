resource "null_resource" "app_ansible_playbook" {
  triggers = {
    build_number = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i ansible/inventories/${terraform.workspace} ansible/app_provision.yaml | tee -a app_provision.log"
  }
  depends_on = [
    aws_route53_record.app,
  ]
}


resource "aws_lb_listener_rule" "default" {
  listener_arn = lookup(local.shared_alb_listeners, local.env)
  #  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.app.fqdn]
  }
}

resource "aws_lb_target_group" "default" {
  name                 = module.label.name
  port                 = 8080
  protocol             = "HTTP"
  vpc_id               = module.shared.vpc_id
  target_type          = "ip"
  deregistration_delay = 15

  health_check {
    path    = "/"
    matcher = "200-399"
    port    = 8080
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "app" {
  target_group_arn = aws_lb_target_group.default.arn
  target_id        = aws_instance.app.private_ip
  port             = 8080
}

resource "aws_route53_record" "app" {
  zone_id = module.shared.public_zoneid
  name    = "${module.label.name}-app.mitlib.net"
  type    = "CNAME"
  ttl     = "300"
  records = [lookup(local.shared_alb_dns, local.env)]
}


resource "aws_route53_record" "app_priv" {
  zone_id = module.shared.private_zoneid
  name    = "${module.label.name}-app"
  type    = "CNAME"
  ttl     = "300"
  records = aws_instance.app.*.private_dns
}

resource "aws_instance" "app" {
  instance_type               = var.app_instance_type
  ami                         = var.ami
  ebs_optimized               = true
  associate_public_ip_address = false
  key_name                    = var.key_name
  subnet_id                   = element(module.shared.private_subnets, 2)
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.get_pubkey_profile.name
  user_data                   = data.template_file.app_user_data.rendered
  tags = {
    "Name" = "${module.label.name}-app"
  }
  root_block_device {
    volume_type = var.volume_type
    volume_size = var.volume_size
  }
}

resource "aws_security_group" "app_sg" {
  name        = "${module.label.name}-app-sg"
  description = "${module.label.name} application security group"
  vpc_id      = module.shared.vpc_id
  tags = {
    "Name" = "${module.label.name}-app-sg"
  }

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = ["${lookup(local.shared_alb_sgids, local.env)}"]
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

data "template_file" "app_user_data" {
  template = file("${path.module}/files/user_data.sh")
  vars = {
    s3_bucket_pubkeys = var.s3_bucket_pubkeys
    s3_bucket_uri     = var.s3_bucket_pubkeys_uri
    ssh_user          = var.ssh_user
  }
}
