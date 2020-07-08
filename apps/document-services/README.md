# Document-services

This folder contains the configuration for the [Document-services](https://github.mit.edu/mitlibraries/docs) ordering system application. It is configured to use a single instance Elastic Beanstalk environment and an RDS database.

Application related environment and Terraform variable values can be changed with out tainting the RDS database. Such changes can be deployed with out losing the contents of the database. Regular maintenance deploys of this application are required in order to update the TLS webserver certificates, the SMTP mail server credentials, and the MIT Merchant Services indentifiers.

### What's created?:
* Single instance Elastic Beanstalk environments configured for PHP
* RDS Database
* S3 Buckets for storing manually generated TLS webserver certificates for use with the application

### Additional Info:
* SSH has been configured to a default key. If additional keys are needed, it may be easiest to add these additional keys through the .ebextensions folder in the app configuration.

## Input Variables
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| cybersource_access_key | Identifier passed to MIT Merchant Services to ensure payments are classified correctly | string | n/a | yes |
| cybersource_profile_id | Identifier passed to MIT Merchant Services to ensure payments are classified correctly | string | n/a | yes |
| eb_instance_class | The class of the EB instance | n/a | yes |
| eb_solution_stack | The solution stack used to to build the EB instance | n/a | yes |
| mail_host | Hostname of external SMTP email server | string | n/a | yes |
| mail_username | Username associated with account used to send email | string | n/a | yes |
| mail_password | Password associated with account used to send email | string | n/a | yes |
| mail_port | Port used to connect to external SMTP email server | string | n/a | yes |
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
| ssh_keypair | SSH Keypair allowed shell login access | string | n/a | yes |
| ssh_subnet_restriction | CIDR subnet mask for network allowed to connect over ssh | string | n/a | yes |
