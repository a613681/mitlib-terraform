## Libstaff Archive

*Note: This is only created in our Terraform `prod` workspace*

This app is used to create an S3 hosted website for the legacy libstaff.mit.edu content. The content has been uploaded to the `libstaff-archive.mitlib.net` S3 bucket. A majority of this content is static HTML and accessible via the web by visiting http://libstaff-archive.mitlib.net (*Restricted to MIT VPN*).

If content is inaccessible by visiting the link above, you may download files directly from the AWS GUI or via the command line using the AWS CLI.

### What's Created
* IAm policy that restricts S3 bucket access to MIT's VPN subnets
* Route53 DNS entry for the Libstaff webserver in the mitlib.net zone
* S3 bucket to store the Libstaff website data

## Input Variables
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| sec\_web\_access\_subnets | Subnets to allow access to the Libstaff website | list(string) | n/a | yes |
