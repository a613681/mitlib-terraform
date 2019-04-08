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
  security_groups      = ["${aws_security_group.ecs.id}"]
  image_id             = "${data.aws_ami.default.id}"
  iam_instance_profile = "${aws_iam_instance_profile.ecs_inst_prof.id}"

  user_data = <<EOT
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.default.name} >> /etc/ecs/ecs.config
    mkdir -p /mnt/efs
    echo "${aws_efs_file_system.default.dns_name}:/ /mnt/efs efs _netdev 0 0" >> /etc/fstab
    mount -a -t efs defaults
    EOT

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "default" {
  name                 = "${module.label.name}-asg"
  max_size             = 4
  min_size             = 2
  desired_capacity     = 2
  force_delete         = true
  vpc_zone_identifier  = ["${module.shared.private_subnets}"]
  target_group_arns    = ["${module.alb_ingress.target_group_arn}"]
  launch_configuration = "${aws_launch_configuration.default.id}"

  tags = ["${concat(
       list(
       map("key", "Name", "value", "${module.label.name}",  "propagate_at_launch", true)))
       }"]
}

#######
# EFS #
#######
resource "aws_security_group" "efs" {
  name        = "${module.label.name}-efs-sg"
  description = "Allow NFS access from Geoweb ECS cluster"
  tags        = "${module.label.tags}"
  vpc_id      = "${module.shared.vpc_id}"

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ecs.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_efs_file_system" "default" {
  creation_token = "${module.label.name}-efs"
  tags           = "${module.label.tags}"
}

resource "aws_efs_mount_target" "default" {
  count           = "${length(module.shared.private_subnets)}"
  file_system_id  = "${aws_efs_file_system.default.id}"
  subnet_id       = "${element(module.shared.private_subnets, count.index)}"
  security_groups = ["${aws_security_group.efs.id}"]
}
