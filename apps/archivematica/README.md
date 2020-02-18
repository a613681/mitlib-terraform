# Archivematica Application Server

This folder contains AWS resources needed for an Archivematica application stack. The Libraries uses this AWS infrastructure for testing and development while maintaining a separate bare metal on-site stack

### What's created?:
* An ec2 instance
* An EFS instance for some test archival content
* A Route53 DNS entry for the Archivematica server

### Additional Info:
* Access is restricted access based on other security group membership
* SSH access is currently allowed from outside the VPC but should likely be prevented in the future
* The vendor requires an instance size that is at least 2CPUs and 8G of RAM

## Input Variables

| Name | Description |
|------|-------------|
| access\_subnets | Subnets to allow TCP/IP access |
| dns\_zone\_id | The zone in which to create the DNS records |
| ec2\_ami | The AMI to use for the EC2 instance |
| ec2\_subnet | Subnet to use for the EC2 instance's IP address |
| efs\_subnet | The subnet to use for the EFS IP address |
| enabled | Enable or disable Route53 changes |
| mount | The location on the EC2 server to mount the EFS instance |

## Outputs

| Name | Description |
|------|-------------|
| eip_public_address | Elasic IP address of the EC2 instance |
| hostname | Hostname of the Archivematica EC2 application server |
