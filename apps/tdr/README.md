# TDR

This folder contains AWS Route53 records for the TDR Drupal site hosted on [Pantheon](https://pantheon.io/).

### What's created?:
* 3 x Route53 DNS records for dev, test, and prod

### Additional Info:
* TDR is only deployed to the Terraform `prod` workspace

## Input Variables
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| r53\_trac\_value | The prod tdr.mitlib.net Trac website DNS CNAME record value | list(string) | n/a | yes |
| r53\_trac\_dev\_value | The tdr\-dev.mitlib.net Trac website DNS CNAME record value | list(string) | n/a | yes |
| r53\_trac\_test\_value | The tdr\-test.mitlib.net Trac website DNS CNAME record value | list(string) | n/a | yes |
