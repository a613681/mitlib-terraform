# Libraries Website

This folder contains AWS resources needed for the Libraries Wordpress based
website.

### What's created?:
* An ec2 instance
* An RDS MariaDB database instance
* An EFS instance for some web content
* A Route53 DNS entry for the webserver

### Additional Info:
* Security groups are created to restrict access based on other security groups
* MITNet SSH access is currently allowed but should likely be prevented in the future
* The document root and all web content should be moved to EFS in the future
* This infrastructure is paired with an Ansible repository on github.mit.edu that does OS/app setup.

## Input Variables

| Name | Description |
|------|-------------|
| vpc\_id | The VPC that the infrastructure should be created in |
| ec2\_subnet | Subnet to use for ec2 host's IP address |
| rds\_username | Username to access the RDS database |
| rds\_password | Password to access the RDS database |
| rds\_subnets | Subnets to use for the RDS database |
| enabled | Enable or disable Route53 changes |
| dns\_zone\_id | The zone in which to create the DNS records |
| efs\_subnet | The subnet to use for the EFS ip |
| mount | The location on the webserver to mount the EFS instance |

## Outputs

| Name | Description |
|------|-------------|
| website_hostname | FQDN of the webserver |
