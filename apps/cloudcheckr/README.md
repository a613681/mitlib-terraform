# Cloudcheckr Application

This folder contains AWS resources needed for the deployment of the Cloudcheckr policies and role.

### What's created?:
* Policy documents associated with the use of Cloudcheckr
* AN IAM Role for the Cloudcheckr application

### Additional Info:
* Cloudcheckr is only deployed to the Terraform `prod` workspace

## Input Variables
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| external\_id | External ID of Cloudcheckr account. | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| role\_arn | ARN of cloudcheckr role. |
