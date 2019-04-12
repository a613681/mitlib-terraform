module "label" {
  source = "git::https://github.com/MITLibraries/tf-mod-name?ref=master"
  name   = "geo-ecs"
}

#######
# IAM #
#######
data "aws_iam_policy_document" "ecs_svc" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ecs_inst" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_svc" {
  name               = "${module.label.name}-ecs-svc"
  tags               = "${module.label.tags}"
  description        = "${module.label.name} service role"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_svc.json}"
}

resource "aws_iam_role_policy_attachment" "ecs_svc_attach" {
  role       = "${aws_iam_role.ecs_svc.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_role" "ecs_inst" {
  name               = "${module.label.name}-ecs-inst"
  tags               = "${module.label.tags}"
  description        = "${module.label.name} ECS instance role"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_inst.json}"
}

resource "aws_iam_role_policy_attachment" "ecs_inst_attach" {
  role       = "${aws_iam_role.ecs_inst.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_inst_prof" {
  name = "${module.label.name}"
  path = "/"
  role = "${aws_iam_role.ecs_inst.id}"

  provisioner "local-exec" {
    command = "sleep 10"
  }
}

###############
# EC2 cluster #
###############
resource "aws_ecs_cluster" "default" {
  name = "${module.label.name}-cluster"
  tags = "${module.label.tags}"
}

resource "aws_security_group" "ecs" {
  name        = "${module.label.name}-sg"
  description = "${module.label.name} cluster security group"
  tags        = "${module.label.tags}"
  vpc_id      = "${module.shared.vpc_id}"

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${lookup(local.shared_alb_sgids, local.env)}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "default" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_configuration" "default" {
  name_prefix          = "${module.label.name}"
  instance_type        = "t3.small"
  security_groups      = ["${aws_security_group.ecs.id}", "${module.shared.bastion_ingress_sgid}"]
  image_id             = "${data.aws_ami.default.id}"
  iam_instance_profile = "${aws_iam_instance_profile.ecs_inst_prof.id}"
  key_name             = "mit-dornera"

  user_data = <<EOT
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.default.name} >> /etc/ecs/ecs.config
    sudo yum -y update && sudo yum install -y amazon-efs-utils
    sudo mkdir -p /mnt/geo_efs
    sudo mkdir -p /mnt/solr_efs
    sudo echo "${aws_efs_file_system.geo_efs.dns_name}:/ /mnt/geo_efs efs _netdev 0 0" >> /etc/fstab
    sudo echo "${aws_efs_file_system.solr_efs.dns_name}:/ /mnt/solr_efs efs _netdev 0 0" >> /etc/fstab
    sudo mount -a -t efs defaults
    sudo chown ec2-user:ec2-user /mnt/geo_efs
    sudo chown ec2-user:ec2-user /mnt/solr_efs
    EOT

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "default" {
  name_prefix          = "${aws_launch_configuration.default.name}-"
  max_size             = 4
  min_size             = 2
  desired_capacity     = 2
  force_delete         = true
  vpc_zone_identifier  = ["${module.shared.private_subnets}"]
  target_group_arns    = ["${module.alb_ingress.target_group_arn}"]
  launch_configuration = "${aws_launch_configuration.default.id}"

  lifecycle {
    create_before_destroy = true
  }

  tags = ["${concat(
       list(
       map("key", "Name", "value", "${module.label.name}",  "propagate_at_launch", true),
       map("key", "terraform", "value", "true",  "propagate_at_launch", true),
       map("key", "environment", "value", "${terraform.workspace}",  "propagate_at_launch", true)))
       }"]
}
