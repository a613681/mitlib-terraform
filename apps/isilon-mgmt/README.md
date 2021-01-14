# isilon-mgmt

This folder contains AWS resources needed for the deployment of a Windows Server 2019 VM with a static IP address for managing the Isilon storage appliances in the IS&T datacenters.

### What's created?:
* An EC2 instance
* A static Elastic IP is assigned

### Additional Info:

### Input Variables
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| ec2_ami | The AMI to use for the EC2 instance | string | n/a | yes |
| ec2\_inst\_type | The instance type for the EC2 instance | string | n/a | yes |
| ec2\_key\_name | SSH key to assign to the EC2 instance | string | n/a | yes |
| ec2\_subnet | Subnet to use for the EC2 instance IP address | string | n/a | yes |
| ec2\_vol\_size | The EC2 volume size to use for the instance | string | n/a | yes |
| ec2\_vol\_type | The EC2 volume type to use for the instance | string | n/a | yes |
| sec\_access\_subnets | Subnets to allow SSH access | string | n/a | yes |
| vpc\_id | The EC2 VPC used to build the server | string | n/a | yes |

### Outputs
| Name | Description |
| eip | Elastic IP address of the new server |

### Additional PowerShell script tasks after VM creation
* Admin users are added  
** User passwords are stored in Parameter Store
* Additional software is added 