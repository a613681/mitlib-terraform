#Create an S3 bucket and policy for storing our SSH public keys
#Move this part +public keys folder to the module?
variable "ssh_public_key_names" {
  default = "alex,mike"
}

resource "aws_s3_bucket" "ssh_public_keys" {
  bucket = "bastion-ssh-pub-keys"
  acl    = "private"

  policy = <<EOF
{
	"Version": "2008-10-17",
	"Id": "Policy142469412148",
	"Statement": [
		{
			"Sid": "Stmt1424694110324",
			"Effect": "Allow",
			"Principal": {
				"AWS": "arn:aws:iam::672626379771:root"
			},
			"Action": [
				"s3:List*",
				"s3:Get*"
			],
			"Resource": "arn:aws:s3:::bastion-ssh-pub-keys"
		}
	]
}
EOF

  tags = "${module.bastion.tags}"
}

resource "aws_s3_bucket_object" "ssh_public_keys" {
  bucket = "${aws_s3_bucket.ssh_public_keys.bucket}"
  key    = "${element(split(",", var.ssh_public_key_names), count.index)}.pub"

  # Make sure that you put files into correct location and name them accordingly (`public_keys/{keyname}.pub`)
  content = "${file("pub_keys/${element(split(",", var.ssh_public_key_names), count.index)}.pub")}"
  count   = "${length(split(",", var.ssh_public_key_names))}"

  depends_on = ["aws_s3_bucket.ssh_public_keys"]
}

module "latest_ami" {
  source = "github.com/mitlibraries/tf-mod-latest-ami?ref=0.11"
}

module "bastion" {
  source                    = "github.com/mitlibraries/tf-mod-bastion-host?ref=0.11"
  name                      = "bastion"
  instance_type             = "t3.nano"
  ami                       = "${module.latest_ami.ec2_linux_ami_id}"
  region                    = "${var.aws_region}"
  key_name                  = "mit-mgraves"
  iam_instance_profile      = "s3_readonly-allow_associateaddress-${terraform.workspace}"
  s3_bucket_name            = "${aws_s3_bucket.ssh_public_keys.bucket}"
  vpc_id                    = "${module.shared.vpc_id}"
  allowed_cidr              = ["18.28.0.0/16", "18.30.0.0/16"]
  logzio_token              = "${var.logzio_token}"
  subnet_ids                = ["${module.shared.public_subnets}"]
  eip                       = "${aws_eip.bastion.public_ip}"
  apply_changes_immediately = "true"
  keys_update_frequency     = "0 0 * * 0"

  additional_user_data_script = <<EOF
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
aws ec2 associate-address --region $REGION --instance-id $INSTANCE_ID --allocation-id ${aws_eip.bastion.id}
EOF
}

#Create Route53 record
resource "aws_eip" "bastion" {
  vpc = true

  tags = "${module.bastion.tags}"
}

resource "aws_route53_record" "bastion" {
  zone_id = "${module.shared.public_zoneid}"
  name    = "${module.bastion.name}.mitlib.net"
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.bastion.public_ip}"]
}
