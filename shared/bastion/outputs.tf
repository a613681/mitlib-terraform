output "ingress_from_bastion_sg_id" {
  value = "${aws_security_group.from_bastion_sg.id}"
}
