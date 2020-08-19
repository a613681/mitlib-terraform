# Archivematica Application Server

This folder contains the AWS resources needed for an Archivematica application stack. The Libraries uses this AWS infrastructure for testing and development while maintaining a separate bare metal on-site stack.

### What's created?:
* An EC2 instance
* An EFS instance for some test archival content
* A Route53 DNS entry for the Archivematica server

### Additional Info:
* EFS access is restricted based on security group membership
* This application lacks local Ansible code because a vendor configuration Playbook is used

## Input Variables
| Name | Description |
|------|-------------|
| ec2\_ami | The AMI to use for the EC2 instance |
| ec2\_inst\_type | The instance type for the EC2 instance |
| ec2\_key\_name | SSH key to assign to the EC2 instance |
| ec2\_subnet | Subnet to use for the EC2 instance IP address |
| ec2\_vol\_size | The EC2 volume size to use for the instance |
| ec2\_vol\_type | The EC2 volume type to use for the instance |
| efs\_mount | The location on the EC2 server to mount the EFS instance |
| efs\_subnet | The subnet to use for the EFS mount target |
| r53\_dns\_zone\_id | The ID of the zone in which to create the DNS record |
| r53\_enabled | Enable or disable Route53 changes |
| sec\_ss\_access\_subnets | Subnets to allow access to the Archivematica Storage Service web UI |
| sec\_ssh\_access\_subnets | Subnets to allow SSH access |
| sec\_web\_access\_subnets | Subnets to allow access to the Archivematica web UI |

## Outputs
| Name | Description |
|------|-------------|
| eip_public_address | Elasic IP address of the EC2 instance |
| hostname | Hostname of the Archivematica EC2 application server |
