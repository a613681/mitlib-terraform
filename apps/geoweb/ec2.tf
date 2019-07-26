resource "aws_security_group" "geoserver" {
  name        = "geoserver-${module.label.name}"
  description = "Security group associated with GeoServer instance."
  vpc_id      = "${module.shared.vpc_id}"
  tags        = "${module.label.tags}"

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = ["${aws_security_group.geoblacklight.id}"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${module.shared.bastion_ingress_sgid}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "solr" {
  name        = "solr-${module.label.name}"
  description = "Security group associated with Solr instance."
  vpc_id      = "${module.shared.vpc_id}"
  tags        = "${module.label.tags}"

  ingress {
    from_port       = 8983
    to_port         = 8983
    protocol        = "tcp"
    security_groups = ["${aws_security_group.geoblacklight.id}"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${module.shared.bastion_ingress_sgid}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "geoserver" {
  source          = "./modules/ec2"
  name            = "geoserver"
  vpc             = "${module.shared.vpc_id}"
  subnet          = "${module.shared.private_subnets[0]}"
  mount           = "/mnt/geoserver"
  security_groups = ["${aws_security_group.geoserver.id}"]
  key_name        = "mit-mgraves"
  zone            = "${module.shared.private_zoneid}"
}

module "solr" {
  source          = "./modules/ec2"
  name            = "solr"
  vpc             = "${module.shared.vpc_id}"
  subnet          = "${module.shared.private_subnets[0]}"
  mount           = "/mnt/solr"
  security_groups = ["${aws_security_group.solr.id}"]
  key_name        = "mit-mgraves"
  zone            = "${module.shared.private_zoneid}"
}
