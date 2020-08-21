# Dome Application Server

This folder contains the AWS resources needed for an Dome application stack. Dome is a DSpace digital repository instance.

### What's Created
* An EC2 instance
* An EFS instance for licensed and archival content
* An RDS database instance
* A Route53 DNS entry for the Dome server

### Additional Info
* EFS access is restricted based on security group membership

## Input Variables
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| ec2\_ami | The AMI to use for the EC2 instance | string | n/a | yes |
| ec2\_inst\_type | The instance type for the EC2 instance | string | n/a | yes |
| ec2\_key\_name | SSH key to assign to the EC2 instance | string | n/a | yes |
| ec2\_subnet | Subnet to use for the EC2 instance IP address | string | n/a | yes |
| ec2\_vol\_size | The EC2 volume size to use for the instance | string | n/a | yes |
| ec2\_vol\_type | The EC2 volume type to use for the instance | string | n/a | yes |
| r53\_dns\_zone\_id | The ID of the zone in which to create the DNS record | string | n/a | yes |
| r53\_enabled | Enable or disable Route53 changes (number of records to change) | number | 0 | yes |
| rds\_engine | RDS database engine | string | n/a | yes |
| rds\_maj\_eng\_ver | RDS database major engine version | string | n/a | yes |
| rds\_eng\_ver | RDS database engine version | string | n/a | yes |
| rds\_maj\_upgrade | Allow automated RDS database major engine version upgrade | string | n/a | yes |
| rds\_apply\_immediately | Apply database modifications immediately or during next maintenance window | string | n/a | yes |
| rds\_inst\_class | Class of the RDS instance | string | n/a | yes |
| rds\_storage | The amount of storage for the RDS instance in GB | string | n/a | yes |
| rds\_db\_name | The RDS database name | string | n/a | yes |
| rds\_port | The TCP port for the RDS instance to use | string | n/a | yes |
| rds\_param\_grp | The RDS parameter group to use with the RDS database | string | "" | no |
| rds\_maint\_win | RDS maintenance window | string | "" | no |
| rds\_backup\_win | RDS database backup window | string | "" | no |
| rds\_backup\_retain | RDS backup retention period | string | "0" | no |
| rds\_username | Username to access the RDS database | string | n/a | yes |
| rds\_password | Password to access the RDS database | string | n/a | yes |
| rds\_subnets | Subnets to use for the RDS database | string | n/a | yes |
| sec\_handle\_access\_subnets | Subnets to allow Handle server access | string | n/a | yes |
| sec\_ssh\_access\_subnets | Subnets to allow SSH access | string | n/a | yes |
| sec\_web\_access\_subnets | Subnets to allow access to the Dome web UI | string | n/a | yes |

## Outputs
| Name | Description |
|------|-------------|
| eip\_public\_address | Elastic IP address of the new Dome server |
