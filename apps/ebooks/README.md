# Ebook Delivery Application

This folder contains AWS resources needed for the deployment of the [Ebook Delivery Application](https://github.com/MITLibraries/ebooks). The application itself is deployed to Heroku, but additional AWS resources are needed for storage and file interaction.

### What's created?:
* An S3 bucket for storing Ebook files
* An IAM user/credentials with read only access to the S3 Bucket (used by Heroku application)
* A role which is maintained via an MIT Moira list for catalogers to upload new files to the S3 bucket

### Additional Info:
* Ebooks is only deployed to the Terraform `prod` workspace


## Outputs

| Name | Description |
|------|-------------|
| access\_key\_id | The access key ID for app to use |
| secret\_access\_key | The secret access key for app to use. This will be written to the state file in plain-text |
