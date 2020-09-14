# Open Access Task Force

This folder contains AWS Route53 records for the Open Access Task Force Drupal site hosted on [Pantheon](https://pantheon.io/).

### What's created?:
* 3 x Route53 DNS records for dev, test, and prod

### Additional Info:
* Open Access Task Force is only deployed to the Terraform `prod` workspace

## Input Variables
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| r53\_oatf\_value | The prod open\-access.mitlib.net website DNS CNAME record value | list(string) | n/a | yes |
| r53\_oatf\_dev\_value | The open\-access\-dev.mitlib.net website DNS CNAME record value | list(string) | n/a | yes |
| r53\_oatf\_test\_value | The open\-access\-test.mitlib.net website DNS CNAME record value | list(string) | n/a | yes |
