# Bastion Host

The main purpose of a bastion host is to allow access to resources inside of our VPC. We restrict access from the public internet to our bastion hosts, and allow access from the bastion hosts to our internal resources via security groups. Ideally, a majority of our resources will be on private subnets, behind Application Load Balancers, and only accessed from the public via HTTP and HTTPS.

Currently we are using the default `ec2-user`. So when SSH'ing into the bastion host, make sure you use `ssh ec2-user@bastion-<workspace>.mitlib.net`.

#### What's created
* S3 Bucket to store public SSH keys (these are located in the pub_keys folder)
* Bastion host EC2 instance
  * Cron script is run on host in case there are any updated keys (see [bastion module](https://github.com/MITLibraries/tf-mod-bastion-host))
* Route53 record for DNS name for bastion host
* Security group that can be assigned to resources for acesss from bastion host


#### Use Cases
* SSH Access to an ECS Cluster
* Working with RDS databases on private subnets (imports, exports, etc.)
* SSH access to other instances on private subnets
