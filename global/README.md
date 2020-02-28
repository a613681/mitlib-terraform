# Global AWS Infrastructure

This folder contains global scope AWS resources needed for MIT Libraries architecture. This includes resources that span both stage and prod VPCs. The resources should be deployed in the "global" Terraform workspace.

### What's created?:
* ACM cert CNAME for mitlib.net zone validation
* Docsvcs EBS application
* IAM users
* Initial tfstate locking DB
* Route53 mitlib.net zone
* SAML integration resources

### Additional Info:
* The IAM code will need to be modified if we begin making use of IAM groups for access controls rather than policies.
* The MIT-IdP-metadata.xml file for SAML integration should be updated from time to time.

## Input Variables

| Name | Description |
|------|-------------|
| admins | IAM user accounts to add to the administrators IAM group |
| users | IAM user accounts to be created |

## Outputs

| Name | Description |
|------|-------------|
| public_zoneid | Route53 Public Zone ID |
| public_zonename | Route53 Public Zone name |
| private_zoneid | Route53 Private Zone ID |
| private_zonename | Route53 Private Zone name |
| mitlib_cert | mitlib.net wildcard certificate |
| mit_saml_arn | MIT Identity provider arn (SAML Federated login) |
| docsvcs_beanstalk_name | Name of Docsvcs Elastic Beanstalk application |
| admin_accounts | Names of the administrator accounts |
| user_account_arns | ARNs of the user accounts |
