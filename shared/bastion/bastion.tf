module "latest_ami" {
  source = "github.com/mitlibraries/tf-mod-latest-ami?ref=0.12"
}

# S3 bucket and policy for storing our SSH public keys
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


  tags = module.bastion.tags
}

# Load the public SSH keys from the S3 bucket
resource "aws_s3_bucket_object" "ssh_public_keys" {
  bucket = aws_s3_bucket.ssh_public_keys.bucket
  key    = "${element(split(",", var.sec_ssh_public_keys), count.index)}.pub"

  # Make sure that you put files into correct location and name them accordingly (`public_keys/{keyname}.pub`)
  content = file(
    "pub_keys/${element(split(",", var.sec_ssh_public_keys), count.index)}.pub",
  )
  count = length(split(",", var.sec_ssh_public_keys))

  depends_on = [aws_s3_bucket.ssh_public_keys]
}

# Create the ec2 bastion host and associated auto-scaling group
module "bastion" {
  source                    = "github.com/mitlibraries/tf-mod-bastion-host?ref=0.12"
  name                      = "bastion"
  instance_type             = var.ec2_inst_type
  ami                       = module.latest_ami.ec2_linux_ami_id
  region                    = var.aws_region
  key_name                  = var.ec2_key_name
  iam_instance_profile      = "s3_readonly-allow_associateaddress-${terraform.workspace}"
  s3_bucket_name            = aws_s3_bucket.ssh_public_keys.bucket
  vpc_id                    = module.shared.vpc_id
  allowed_cidr              = var.sec_ssh_access_subnets
  logzio_token              = var.logzio_token
  subnet_ids                = module.shared.public_subnets
  eip                       = aws_eip.bastion.public_ip
  apply_changes_immediately = "true"
  keys_update_frequency     = "0 0 * * 0"

  additional_user_data_script = <<EOF
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
aws ec2 associate-address --region $REGION --instance-id $INSTANCE_ID --allocation-id ${aws_eip.bastion.id}
EOF

}

# Create an Elastic IP for the bastion host
resource "aws_eip" "bastion" {
  vpc = true

  tags = module.bastion.tags
}

# Create Route53 record
resource "aws_route53_record" "bastion" {
  zone_id = var.r53_dns_zone_id
  name    = "${module.bastion.name}.mitlib.net"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.bastion.public_ip]
}
