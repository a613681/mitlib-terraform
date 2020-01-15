# dos

This folder contains AWS resources needed for the Digital Object Store

### What's created?:
* An S3 bucket for storing digital objects
* An IAM policy for admin level access to that S3 bucket
* IAM policy attachments to IAM users in the "users" list variable

### Additional Info:
* Files are uploaded to the S3 bucket manually
* Security and access policy configuration is currently minimal as the project is in an early development stage
* Web service is currently not configured

## Input Variables

| Name | Description |
|------|-------------|
| users | List of users that should have access to the bucket |

## Outputs

| Name | Description |
|------|-------------|
| bucket\_arn | ARN of the S3 bucket |
| bucket\_name | Name (ID) of the S3 bucket |
