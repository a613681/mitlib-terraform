# Bastion Host

The main purpose of a bastion host is to allow access to resources inside of our VPC over the internal private subnet. We restrict access from the public internet to our bastion hosts and control access from the bastion hosts to our internal resources via security groups.

Currently we are using the default `ec2-user`. The following ssh command would allow you to the appropriate bastion host: `ssh ec2-user@bastion-<workspace>.mitlib.net`.

### What's created
* Auto-scaling group configured to always keep one bastion host running for each VPC
* Bastion host EC2 instance (using the latest Amazon Linux AMI)
  * Cron script run on the bastion host to install updated SSH keys (see [bastion module](https://github.com/MITLibraries/tf-mod-bastion-host))
* Route53 record for the bastion host
* S3 Bucket to store SSH public keys
* Security group that can be assigned to resources for access from bastion host

### Use Cases
* SSH access to an ECS cluster
* SSH access to EC2 instances
* Working with RDS databases on private subnets (imports, exports, etc.)

## Input Variables
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| aws\_region | The AWS region to create the EC2 instance in | string | us-east-1 | no |
| ec2\_inst\_type | The instance type for the EC2 instance | string | n/a | yes |
| ec2\_key\_name | SSH key to assign to the EC2 instance | string | n/a | yes |
| logzio\_token | Secret logz.io API token for shipping logs | string | n/a | yes |
| r53\_dns\_zone\_id | The ID of the zone in which to create the DNS record | string | n/a | yes |
| sec\_ssh\_access\_subnets | Subnets to allow SSH access | string | n/a | yes |
| sec\_ssh\_public\_keys | List of SSH public keys from the S3 bucket to allow access | string | n/a | yes |

## Outputs
| Name | Description |
|------|-------------|
| eip\_public\_address | Public IP of the bastion host |
| ingress\_from\_bastion\_sg\_id | Bastion host Security Group ID |
