# EZproxy Lookup Application

This folder contains AWS resources needed for the deployment of the [EZproxy Lookup Application](https://github.com/MITLibraries/ezproxy-lookup). The application itself is deployed to Heroku, but additional AWS resources are needed for storage and file interaction.

### What's created?:
* An S3 bucket for storing files
* An IAM user/credentials with read only access to the S3 Bucket (used by Heroku application)
* A role which is maintained via an MIT Moira list for staff to upload new files to the S3 bucket

## Outputs

| Name | Description |
|------|-------------|
| access\_key\_id | The access key ID for app to use |
| secret\_access\_key | The secret access key for app to use. This will be written to the state file in plain-text |
